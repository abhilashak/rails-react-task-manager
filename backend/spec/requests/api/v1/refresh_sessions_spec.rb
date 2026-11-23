
require "rails_helper"
require "digest"

RSpec.describe "API V1 Refresh Sessions", type: :request do
  let(:user) { create(:user) }

  let(:origin) do
    { "Origin" => "http://localhost:5173" }
  end

  let(:raw_token) do
    Authentication::RefreshToken.issue(user)
  end

  let(:refresh_cookie) do
    { "Cookie" => "refresh_token=#{raw_token}" }
  end

  let(:refresh_session) do
    RefreshSession.find_by!(
      token_digest: Digest::SHA256.hexdigest(raw_token)
    )
  end

  describe "POST /api/v1/auth/refresh" do
    it "rotates the refresh token and returns a new access token" do
      post "/api/v1/auth/refresh",
           headers: origin.merge(refresh_cookie)

      expect(response).to have_http_status(:ok)

      body = response.parsed_body

      expect(body.dig("data", "access_token")).to be_present
      expect(body.dig("data", "token_type")).to eq("Bearer")
      expect(body.dig("data", "user", "id")).to eq(user.id)

      new_token = response.cookies["refresh_token"]

      expect(new_token).to be_present
      expect(new_token).not_to eq(raw_token)

      expect(refresh_session.reload.rotated_at).to be_present

      new_digest = Digest::SHA256.hexdigest(new_token)
      expect(RefreshSession.exists?(token_digest: new_digest)).to be(true)
    end

    it "rejects an invalid refresh token" do
      post "/api/v1/auth/refresh",
           headers: origin.merge("Cookie" => "refresh_token=invalid-token")

      expect(response).to have_http_status(:unauthorized)
    end

    it "rejects refresh requests without a cookie" do
      post "/api/v1/auth/refresh", headers: origin

      expect(response).to have_http_status(:unauthorized)
    end

    it "rejects requests from an untrusted origin" do
      post "/api/v1/auth/refresh",
           headers: {
             "Origin" => "https://malicious.example.com"
           }

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "DELETE /api/v1/auth/logout" do
    it "revokes the refresh token family" do
      delete "/api/v1/auth/logout",
             headers: origin.merge(refresh_cookie)

      expect(response).to have_http_status(:no_content)
      expect(refresh_session.reload.revoked_at).to be_present
    end

    it "returns no content even when no refresh token exists" do
      delete "/api/v1/auth/logout", headers: origin

      expect(response).to have_http_status(:no_content)
    end
  end
end

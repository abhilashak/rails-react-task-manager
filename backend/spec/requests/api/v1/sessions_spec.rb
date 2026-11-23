
require "rails_helper"

RSpec.describe "API V1 Sessions", type: :request do
  let(:endpoint) { "/api/v1/auth/login" }

  let(:user) do
    create(
      :user,
      email: "test@example.com",
      password: "password@1"
    )
  end

  let(:valid_params) do
    {
      login: {
        email: user.email,
        password: "password@1"
      }
    }
  end

  let(:invalid_response) do
    {
      "errors" => ["Invalid email or password"]
    }
  end

  describe "POST /api/v1/auth/login" do
    context "with valid credentials" do
      it "returns 200 OK" do
        post endpoint, params: valid_params, as: :json

        expect(response).to have_http_status(:ok)
      end

      it "returns an access token" do
        post endpoint, params: valid_params, as: :json

        body = response.parsed_body

        expect(body.dig("data", "access_token")).to be_present
        expect(body.dig("data", "token_type")).to eq("Bearer")
        expect(body.dig("data", "expires_in"))
          .to eq(Authentication::Base::ACCESS_TOKEN_TTL.to_i)
      end

      it "returns the authenticated user" do
        post endpoint, params: valid_params, as: :json

        expect(response.parsed_body.dig("data", "user")).to eq(
          {
            "id" => user.id,
            "email" => user.email
          }
        )
      end

      it "generates a valid JWT for the authenticated user" do
        post endpoint, params: valid_params, as: :json

        token = response.parsed_body.dig("data", "access_token")

        payload = Authentication::TokenVerifier.verify(token)

        expect(payload).to be_a(Hash)
        expect(payload["sub"]).to eq(user.id.to_s)
      end

      it "does not expose sensitive user attributes" do
        post endpoint, params: valid_params, as: :json

        body = response.parsed_body

        expect(body.dig("data", "user").keys)
          .to contain_exactly("id", "email")

        expect(body.to_json).not_to include("password_digest")
        expect(body.to_json).not_to include("password")
      end
    end

    context "with invalid credentials" do
      it "rejects an incorrect password" do
        params = valid_params.deep_merge(
          login: { password: "wrong-password" }
        )

        post endpoint, params: params, as: :json

        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to eq(invalid_response)
      end

      it "rejects a non-existent email" do
        params = {
          login: {
            email: "unknown@example.com",
            password: "password@1"
          }
        }

        post endpoint, params: params, as: :json

        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to eq(invalid_response)
      end

      it "rejects a missing email" do
        params = valid_params.deep_merge(
          login: { email: nil }
        )

        post endpoint, params: params, as: :json

        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to eq(invalid_response)
      end

      it "rejects a missing password" do
        params = valid_params.deep_merge(
          login: { password: nil }
        )

        post endpoint, params: params, as: :json

        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to eq(invalid_response)
      end

      it "uses the same response for unknown email and incorrect password" do
        invalid_password_params = valid_params.deep_merge(
          login: { password: "wrong-password" }
        )

        post endpoint, params: invalid_password_params, as: :json

        first_response = response.parsed_body

        post endpoint,
             params: {
               login: {
                 email: "unknown@example.com",
                 password: "password@1"
               }
             },
             as: :json

        second_response = response.parsed_body

        expect(first_response).to eq(second_response)
      end
    end

    context "with normalized email" do
      it "allows login using uppercase email" do
        params = valid_params.deep_merge(
          login: { email: "TEST@EXAMPLE.COM" }
        )

        post endpoint, params: params, as: :json

        expect(response).to have_http_status(:ok)
      end
    end
  end
end

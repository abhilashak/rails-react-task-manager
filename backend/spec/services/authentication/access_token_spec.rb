require "rails_helper"

RSpec.describe Authentication::AccessToken do
  let(:user) { create(:user) }
  let(:secret) { ENV["JWT_SECRET_KEY"].presence || Rails.application.credentials.dig(:jwt, :secret_key) }

  describe ".issue" do
    context "with a persisted user" do
      let(:token) { described_class.issue(user) }

      it "generates a JWT string" do
        expect(token).to be_a(String)
        expect(token.split(".").size).to eq(3)
      end

      it "contains the correct JWT header" do
        _payload, header = JWT.decode(
          token,
          secret,
          true,
          algorithm: described_class::ALGORITHM
        )

        expect(header["alg"]).to eq("HS256")
      end

      it "contains the correct claims" do
        payload, = JWT.decode(
          token,
          secret,
          true,
          {
            algorithm: described_class::ALGORITHM,
            iss: described_class::ISSUER,
            verify_iss: true,
            aud: described_class::AUDIENCE,
            verify_aud: true,
            required_claims: %w[sub iss aud iat exp jti]
          }
        )

        expect(payload["sub"]).to eq(user.id.to_s)
        expect(payload["iss"]).to eq("task_manager_api")
        expect(payload["aud"]).to eq("task_manager_web")
        expect(payload["iat"]).to be_a(Integer)
        expect(payload["exp"] - payload["iat"]).to eq(10.minutes.to_i)
        expect(payload["jti"]).to be_present
      end

      it "generates a different jti for every token" do
        first_token = described_class.issue(user)
        second_token = described_class.issue(user)

        first_payload = JWT.decode(first_token, secret, true, algorithm: "HS256").first
        second_payload = JWT.decode(second_token, secret, true, algorithm: "HS256").first

        expect(first_payload["jti"]).not_to eq(second_payload["jti"])
      end
    end

    context "without a persisted user" do
      it "raises an error when user is nil" do
        expect {
          described_class.issue(nil)
        }.to raise_error(ArgumentError, Authentication::Error::USER_ERROR)
      end

      it "raises an error when user is not persisted" do
        expect {
          described_class.issue(build(:user))
        }.to raise_error(ArgumentError, Authentication::Error::USER_ERROR)
      end
    end
  end
end

require "rails_helper"

RSpec.describe Authentication::TokenVerifier do
  let(:user) { create(:user) }
  let(:secret) { Rails.application.credentials.dig(:jwt, :secret_key) }
  let(:valid_token) { Authentication::AccessToken.issue(user) }

  let(:decoded_payload) do
    JWT.decode(
      valid_token,
      secret,
      true,
      algorithm: Authentication::Base::ALGORITHM
    ).first
  end

  describe ".verify" do
    context "with a valid token" do
      it "returns the verified payload" do
        result = described_class.verify(valid_token)

        expect(result).to be_a(Hash)
        expect(result["sub"]).to eq(user.id.to_s)
        expect(result["iss"]).to eq(Authentication::Base::ISSUER)
        expect(result["aud"]).to eq(Authentication::Base::AUDIENCE)
      end

      it "returns the jti claim" do
        result = described_class.verify(valid_token)

        expect(result["jti"]).to be_present
      end
    end

    context "with an invalid token" do
      it "returns nil for blank tokens" do
        expect(described_class.verify(nil)).to be_nil
        expect(described_class.verify("")).to be_nil
        expect(described_class.verify("  ")).to be_nil
      end

      it "returns nil for non-string input" do
        expect(described_class.verify(123)).to be_nil
      end

      it "returns nil for malformed tokens" do
        expect(described_class.verify("invalid-token")).to be_nil
      end

      it "returns nil for expired tokens" do
        expired_payload = decoded_payload.merge(
          "exp" => 1.minute.ago.to_i
        )

        token = JWT.encode(
          expired_payload,
          secret,
          Authentication::Base::ALGORITHM
        )

        expect(described_class.verify(token)).to be_nil
      end

      it "returns nil for an invalid signature" do
        token = JWT.encode(
          decoded_payload,
          SecureRandom.hex(32),
          Authentication::Base::ALGORITHM
        )

        expect(described_class.verify(token)).to be_nil
      end

      it "returns nil for an incorrect issuer" do
        payload = decoded_payload.merge(
          "iss" => "untrusted_api"
        )

        token = JWT.encode(
          payload,
          secret,
          Authentication::Base::ALGORITHM
        )

        expect(described_class.verify(token)).to be_nil
      end

      it "returns nil for an incorrect audience" do
        payload = decoded_payload.merge(
          "aud" => "another_application"
        )

        token = JWT.encode(
          payload,
          secret,
          Authentication::Base::ALGORITHM
        )

        expect(described_class.verify(token)).to be_nil
      end

      it "returns nil when a required claim is missing" do
        payload = decoded_payload.except("sub")

        token = JWT.encode(
          payload,
          secret,
          Authentication::Base::ALGORITHM
        )

        expect(described_class.verify(token)).to be_nil
      end

      it "returns nil when issued at is in the future" do
        payload = decoded_payload.merge(
          "iat" => 5.minutes.from_now.to_i
        )

        token = JWT.encode(
          payload,
          secret,
          Authentication::Base::ALGORITHM
        )

        expect(described_class.verify(token)).to be_nil
      end
    end
  end
end

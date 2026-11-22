
require "rails_helper"

RSpec.describe "API V1 Registration", type: :request do
  let(:endpoint) { "/api/v1/auth/register" }

  let(:valid_params) do
    {
      user: {
        email: "test@example.com",
        password: "password@1",
        password_confirmation: "password@1"
      }
    }
  end

  describe "POST /api/v1/auth/register" do
    context "with valid attributes" do
      it "creates a user and returns 201 Created" do
        expect {
          post endpoint, params: valid_params, as: :json
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)

        user = User.find_by!(email: "test@example.com")

        expect(response.parsed_body).to eq(
          {
            "data" => {
              "id" => user.id,
              "email" => user.email
            }
          }
        )

        expect(user.authenticate("password@1")).to be_truthy
      end
    end

    context "with invalid attributes" do
      it "rejects duplicate email" do
        create(:user, email: "test@example.com")

        expect {
          post endpoint, params: valid_params, as: :json
        }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_entity)

        expect(response.parsed_body["errors"])
          .to include("Email has already been taken")
      end

      it "rejects email with different casing" do
        create(:user, email: "test@example.com")

        params = valid_params.deep_merge(
          user: { email: "TEST@EXAMPLE.COM" }
        )

        post endpoint, params: params, as: :json

        expect(response).to have_http_status(:unprocessable_entity)

        expect(response.parsed_body["errors"])
          .to include("Email has already been taken")
      end

      it "rejects missing email" do
        params = valid_params.deep_merge(
          user: { email: nil }
        )

        post endpoint, params: params, as: :json

        expect(response).to have_http_status(:unprocessable_entity)

        expect(response.parsed_body["errors"])
          .to include("Email can't be blank")
      end

      it "rejects missing password" do
        params = valid_params.deep_merge(
          user: {
            password: nil,
            password_confirmation: nil
          }
        )

        post endpoint, params: params, as: :json

        expect(response).to have_http_status(:unprocessable_entity)

        expect(response.parsed_body["errors"])
          .to include("Password can't be blank")
      end

      it "rejects password confirmation mismatch" do
        params = valid_params.deep_merge(
          user: { password_confirmation: "wrong-password" }
        )

        post endpoint, params: params, as: :json

        expect(response).to have_http_status(:unprocessable_entity)

        expect(response.parsed_body["errors"])
          .to include("Password confirmation doesn't match Password")
      end
    end

    context "with malicious mass-assignment attributes" do
      it "does not allow password_digest to be assigned" do
        attacker_digest = SecureRandom.hex(32)

        params = valid_params.deep_merge(
          user: { password_digest: attacker_digest }
        )

        post endpoint, params: params, as: :json

        expect(response).to have_http_status(:created)

        user = User.find_by!(email: "test@example.com")

        expect(user.password_digest).not_to eq(attacker_digest)
        expect(user.authenticate("password@1")).to be_truthy

        expect(response.parsed_body.dig("data").keys)
          .to contain_exactly("id", "email")
      end
    end
  end
end

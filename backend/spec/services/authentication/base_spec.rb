require "rails_helper"

RSpec.describe Authentication::Base do
  describe ".payload" do
    let(:payload) { described_class.payload }

    it "includes the common JWT claims" do
      expect(payload.keys).to include(
        :iss, :aud, :iat, :exp, :jti
      )

      expect(payload).not_to have_key(:sub)
    end

    it "sets the correct issuer and audience" do
      expect(payload[:iss]).to eq("task_manager_api")
      expect(payload[:aud]).to eq("task_manager_web")
    end

    it "sets the expiration relative to issued time" do
      expect(payload[:exp] - payload[:iat]).to eq(10.minutes.to_i)
    end

    it "generates a unique JWT ID" do
      first_payload = described_class.payload
      second_payload = described_class.payload

      expect(first_payload[:jti]).not_to eq(second_payload[:jti])
    end
  end
end
RSpec.describe Authentication::Base do
  context "constants" do
    it "SECRET_KEY, HEADER" do
      expect(described_class::SECRET_KEY.length).to eq(128)
      expect(described_class::HEADER.keys).to include("alg", "typ")
    end
  end

  context "methods" do
    it "payload" do
      user = build(:user)
      payload = described_class.payload(user)
      expect(payload.keys).to include("iss", "aud", "iat", "exp")
      expect(payload.keys).not_to include("sub")
    end
  end
end
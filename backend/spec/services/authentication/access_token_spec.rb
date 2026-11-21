RSpec.describe Authentication::AccessToken do
  context "methods" do
    it "#issue" do
      user = nil
      token = described_class.issue(user)
      expect(token).to be_nil
      user = build(:user)
      token = described_class.issue(user)
      expect(token).not_to be_nil
    end
    
    it "#private payload" do
      user = build(:user)
      payload = described_class.send(:payload, user)
      expect(payload.keys).to include("iss", "aud", "iat", "exp", "sub")
    end
  end
end
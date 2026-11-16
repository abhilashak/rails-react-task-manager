RSpec.describe "Rspec Basics learning" do
  describe "Equality" do
    let(:languages) { ["Ruby", "JavaScript", "Python"] }

    it "check addition" do
      expect(10 + 20).to eq(30)
    end

    it "include in the list" do
      expect(languages).to include "Ruby"
    end

    it "checks nil value" do
      nil_value = nil
      expect(nil_value).to be_nil
    end

    it "checks false value" do
      false_value = false
      true_value = true
      expect(false_value).to be false
      expect(false_value).to be_falsey
      expect(true_value).to be_truthy
      expect(true_value).to be true
    end

    it "checks negative expectation" do
      expect(languages).not_to include "Scala" 
    end
  end
end
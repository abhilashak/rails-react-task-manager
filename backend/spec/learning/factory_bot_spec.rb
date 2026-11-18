require 'rails_helper'

RSpec.describe :user do
  describe "Factory Bot: Build" do
    it "user is valid" do
      user = build(:user)
      expect(user.valid?).to be(true)
    end
    
    it "user is not persisted" do
      user = build(:user)
      expect(user.persisted?).to be(false)
    end
    
    it "email is populated" do
      user = build(:user)
      expect(user.email).not_to be_empty
    end

    it "password authentication works" do
      user = build(:user)
      expect(user.authenticate('password@1')).to be_truthy
    end
  end

  describe "Factory Bot: Create" do
    it "valid user" do
      user = create(:user)
      expect(user.valid?).to be(true)
    end

    it "user persisted and has an id matches User.find" do
      user = create(:user)
      expect(user.persisted?).to be(true)
      expect(user.id.is_a?(Integer)).to eq(true)
      find_user = User.find(user.id)
      expect(find_user).to eql(user)
    end
  end

  describe "Factory Bot: Attribute override" do
    it "update email" do
      user1 = create(:user)
      user2 = create(:user)
      user1.update(email: 'emailTest1@example.com')
      expect(user1.email).to eq('emailtest1@example.com')
      user2.update(email: 'emailTest2@example.com')
      expect(user2.email).to eq('emailtest2@example.com')
    end
  end
end
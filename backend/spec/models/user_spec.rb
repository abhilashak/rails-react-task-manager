require 'rails_helper'

RSpec.describe User, type: :model do
  let(:valid_user) { described_class.create!(email: "email@example.com", password: "password@1") }
  let(:non_persisted_user) { described_class.new(email: "  EMAIL@example.com  ", password: "Pass12#") }

  describe "validations" do
    context "valid user" do
      it "check valid user" do
        expect(non_persisted_user.valid?).to be_truthy
      end

      it "check email, password presence" do
        non_persisted_user.valid?
        expect(non_persisted_user.email).not_to be_empty
        expect(non_persisted_user.password).not_to be_empty
      end
    end

    context "invalid user" do
      it "missing email, password, password digest" do
        invalid_user = described_class.new(email: "", password: "")
        invalid_user.valid?
        expect(invalid_user.errors.full_messages).to include("Email can't be blank")
        expect(invalid_user.errors.full_messages).to include("Password can't be blank")
        expect(invalid_user.errors.full_messages).to include("Password digest can't be blank")
      end

      it "throw error email not unique" do
        valid_user
        invalid_user = described_class.new(email: " EMAIL@EXAMPLE.com", password: "password@1")
        invalid_user.valid?
        expect(invalid_user.errors.full_messages).to include("Email has already been taken")
      end
    end
  end

  describe "email normalization" do
    it "email normalization when validation happens" do
      non_persisted_user.valid?
      expect(non_persisted_user.email).to eq("email@example.com")
    end

    it "email normalization when assignment" do
      new_user = described_class.new
      new_user.email = "  MYEMAIL@GMAIL.COM "
      expect(new_user.email).to eq("myemail@gmail.com")
    end

    it "checks email normalized after saving" do
      non_persisted_user.save!
      expect(non_persisted_user.email).to eq("email@example.com")
    end
  end

  describe "Passwords" do
    context "Passwords authentication" do
      it "checks valid authentication if email and password provided" do
        result = valid_user.authenticate("password@1")
        expect(result).to equal(valid_user)
      end

      it "checks invalid authentication if wrong password given" do
        result = valid_user.authenticate("wrong-pass12")
        expect(result).to be(false)
      end
    end

    context "Password digest" do
      it "checks password digest is present" do
        expect(valid_user.password_digest).not_to be_empty
      end

      it "password digest does not equal the original password" do
        expect(valid_user.password_digest).not_to eq(valid_user.password)
      end
    end

    context "With Traits" do
      it "verify with password confirmation" do
        user = build(:user, :with_password_confirmation)
        expect(user.valid?).to eq(true)
      end
      it "verify with invalid password confirmation" do
        user = build(:user, :with_invalid_password_confirmation)
        expect(user.valid?).to eq(false)
        expect(user.errors.full_messages).to include("Password confirmation doesn't match Password")
      end
    end
  end
end

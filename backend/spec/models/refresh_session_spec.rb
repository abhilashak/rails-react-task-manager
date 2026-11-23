
require "rails_helper"

RSpec.describe RefreshSession, type: :model do
  describe "associations" do
    it "belongs to a user" do
      refresh_session = build(:refresh_session)

      expect(refresh_session.user).to be_a(User)
    end

    it "requires an associated user" do
      refresh_session = build(:refresh_session, user: nil)

      expect(refresh_session).not_to be_valid
      expect(refresh_session.errors[:user]).to be_present
    end

    it "is accessible through the user's refresh_sessions association" do
      refresh_session = create(:refresh_session)

      expect(refresh_session.user.refresh_sessions)
        .to include(refresh_session)
    end
  end

  describe "validations" do
    it "is valid with valid attributes" do
      refresh_session = build(:refresh_session)

      expect(refresh_session).to be_valid
    end

    it "requires token_digest" do
      refresh_session = build(:refresh_session, token_digest: nil)

      expect(refresh_session).not_to be_valid
      expect(refresh_session.errors[:token_digest]).to include("can't be blank")
    end

    it "requires a unique token_digest" do
      existing_session = create(:refresh_session)

      duplicate_session = build(
        :refresh_session,
        token_digest: existing_session.token_digest
      )

      expect(duplicate_session).not_to be_valid

      expect(duplicate_session.errors[:token_digest])
        .to include("has already been taken")
    end

    it "requires family_id" do
      refresh_session = build(:refresh_session, family_id: nil)

      expect(refresh_session).not_to be_valid
      expect(refresh_session.errors[:family_id]).to include("can't be blank")
    end

    it "requires expires_at" do
      refresh_session = build(:refresh_session, expires_at: nil)

      expect(refresh_session).not_to be_valid
      expect(refresh_session.errors[:expires_at]).to include("can't be blank")
    end
  end
end

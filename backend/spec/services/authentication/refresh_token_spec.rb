
require "rails_helper"
require "digest"

RSpec.describe Authentication::RefreshToken do
  let(:user) { create(:user) }
  let(:raw_token) { described_class.issue(user) }

  let(:token_digest) do
    Digest::SHA256.hexdigest(raw_token)
  end

  describe ".issue" do
    it "generates a random refresh token" do
      token = described_class.issue(user)

      expect(token).to be_a(String)
      expect(token).to be_present
    end

    it "stores only the token digest" do
      token = raw_token

      session = RefreshSession.find_by!(
        token_digest: token_digest
      )

      expect(session.token_digest).not_to eq(token)
      expect(session.user).to eq(user)
    end

    it "sets the expiry" do
      token = raw_token
      session = RefreshSession.find_by!(token_digest: token_digest)

      expect(session.expires_at)
        .to be_within(5.seconds)
        .of(7.days.from_now)
    end

    it "rejects an unsaved user" do
      expect {
        described_class.issue(build(:user))
      }.to raise_error(ArgumentError)
    end
  end

  describe ".rotate" do
    it "rotates a valid token" do
      old_token = raw_token
      old_session = RefreshSession.find_by!(token_digest: token_digest)

      result = described_class.rotate(old_token)

      expect(result).to be_a(described_class::Result)
      expect(result.user).to eq(user)
      expect(result.token).to be_present
      expect(result.token).not_to eq(old_token)

      old_session.reload

      expect(old_session.revoked_at).to be_present
      expect(old_session.rotated_at).to be_present

      new_digest = Digest::SHA256.hexdigest(result.token)
      new_session = RefreshSession.find_by!(token_digest: new_digest)

      expect(new_session.family_id).to eq(old_session.family_id)
    end

    it "returns nil for an unknown token" do
      expect(described_class.rotate("unknown-token")).to be_nil
    end

    it "returns nil for an expired token" do
      token = raw_token
      session = RefreshSession.find_by!(token_digest: token_digest)

      session.update!(expires_at: 1.minute.ago)

      expect(described_class.rotate(token)).to be_nil
    end

    it "returns nil for a revoked token" do
      token = raw_token
      session = RefreshSession.find_by!(token_digest: token_digest)

      session.update!(revoked_at: Time.current)

      expect(described_class.rotate(token)).to be_nil
    end

    it "revokes the token family when a rotated token is reused" do
      old_token = raw_token

      first_result = described_class.rotate(old_token)

      expect(first_result).to be_present

      replay_result = described_class.rotate(old_token)

      expect(replay_result).to be_nil

      new_digest = Digest::SHA256.hexdigest(first_result.token)
      replacement_session = RefreshSession.find_by!(token_digest: new_digest)

      expect(replacement_session.reload.revoked_at).to be_present
    end

    it "returns nil for blank input" do
      expect(described_class.rotate(nil)).to be_nil
      expect(described_class.rotate("")).to be_nil
    end
  end

  describe ".revoke" do
    it "revokes the token family" do
      token = raw_token
      session = RefreshSession.find_by!(token_digest: token_digest)

      result = described_class.revoke(token)

      expect(result).to be(true)
      expect(session.reload.revoked_at).to be_present
    end

    it "returns false for an unknown token" do
      expect(described_class.revoke("unknown-token")).to be(false)
    end
  end
end

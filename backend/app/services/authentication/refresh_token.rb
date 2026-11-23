
require "securerandom"
require "digest"

module Authentication
  class RefreshToken
    TTL = 7.days
    TOKEN_BYTES = 64

    Result = Struct.new(:user, :token, keyword_init: true)

    class << self
      def issue(user)
        raise ArgumentError, "A persisted user is required" unless user&.persisted?

        token = generate_token

        create_session(
          user,
          token,
          SecureRandom.uuid
        )

        token
      end

      def rotate(raw_token)
        return nil unless valid_token?(raw_token)

        RefreshSession.transaction do
          session = RefreshSession.lock.find_by(
            token_digest: digest(raw_token)
          )

          next nil unless session

          now = Time.current

          # Expired tokens cannot be reused to trigger family revocation.
          next nil if session.expires_at <= now

          # A previously rotated token has been presented again.
          # Revoke all still-active sessions in its family.
          if session.rotated_at.present?
            revoke_family(session.family_id, now)
            next nil
          end

          next nil if session.revoked_at.present?

          user = session.user
          new_token = generate_token

          create_session(user, new_token, session.family_id)

          session.update!(
            revoked_at: now,
            rotated_at: now
          )

          Result.new(user: user, token: new_token)
        end
      end

      def revoke(raw_token)
        return false unless valid_token?(raw_token)

        RefreshSession.transaction do
          session = RefreshSession.lock.find_by(
            token_digest: digest(raw_token)
          )

          next false unless session

          revoke_family(session.family_id, Time.current)

          true
        end
      end

      private

      def generate_token
        SecureRandom.urlsafe_base64(TOKEN_BYTES)
      end

      def digest(token)
        Digest::SHA256.hexdigest(token)
      end

      def valid_token?(token)
        token.is_a?(String) &&
          token.present? &&
          token.bytesize <= 512
      end

      def create_session(user, token, family_id)
        user.refresh_sessions.create!(
          token_digest: digest(token),
          family_id: family_id,
          expires_at: TTL.from_now
        )
      end

      def revoke_family(family_id, time)
        RefreshSession
          .where(family_id: family_id, revoked_at: nil)
          .update_all(revoked_at: time, updated_at: time)
      end
    end
  end
end

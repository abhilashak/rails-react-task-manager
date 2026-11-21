
# frozen_string_literal: true

require "securerandom"

module Authentication
  class Base
    extend Error

    ALGORITHM = "HS256"
    ISSUER = "task_manager_api"
    AUDIENCE = "task_manager_web"
    ACCESS_TOKEN_TTL = 10.minutes
    SECRET_BYTE_SIZE = 32

    class << self
      def payload
        now = Time.current.to_i

        {
          iss: ISSUER,
          aud: AUDIENCE,
          iat: now,
          exp: now + ACCESS_TOKEN_TTL.to_i,
          jti: SecureRandom.uuid
        }
      end

      private

      def signing_secret
        secret = Rails.application.credentials.dig(:jwt, :secret_key)

        raise KeyError, Error::SECRET_MISSING if secret.blank?

        if secret.bytesize < SECRET_BYTE_SIZE
          raise KeyError, secret_length(SECRET_BYTE_SIZE)
        end

        secret
      end
    end
  end
end

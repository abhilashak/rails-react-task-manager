
module Authentication
  class TokenVerifier < Base
    class << self
      def verify(token)
        return nil unless token.is_a?(String) && token.present?

        options = {
          algorithm: Base::ALGORITHM,
          iss: Base::ISSUER,
          verify_iss: true,
          aud: Base::AUDIENCE,
          verify_aud: true,
          verify_expiration: true,
          verify_iat: true,
          verify_jti: true,
          required_claims: %w[sub iss aud iat exp jti]
        }

        payload, = JWT.decode(token, signing_secret, true, options)

        return nil unless valid?(payload["sub"])
        return nil unless valid?(payload["jti"])

        payload
      rescue JWT::TokenError
        nil
      end

      private

      def valid?(item)
        item.is_a?(String) && item.present?
      end
    end
  end
end

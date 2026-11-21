module Authentication
  class AccessToken < Base
    class << self
      def issue(user)
        unless user&.persisted?
          raise ArgumentError, Error::USER_ERROR
        end

        token_payload = payload.merge(sub: user.id.to_s)

        JWT.encode(token_payload, signing_secret, Base::ALGORITHM)
      end
    end
  end
end
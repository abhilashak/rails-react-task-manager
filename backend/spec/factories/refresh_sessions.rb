require "digest"
require "securerandom"

FactoryBot.define do
  factory :refresh_session do
    association :user

    token_digest do
      Digest::SHA256.hexdigest(
        SecureRandom.urlsafe_base64(64)
      )
    end

    family_id { SecureRandom.uuid }

    expires_at { 7.days.from_now }
  end
end
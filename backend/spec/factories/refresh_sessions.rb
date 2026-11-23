FactoryBot.define do
  factory :refresh_session do
    user { nil }
    token_digest { "MyString" }
    family_id { "" }
    expires_at { "2026-11-23 16:14:42" }
    revoked_at { "2026-11-23 16:14:42" }
    rotated_at { "2026-11-23 16:14:42" }
  end
end

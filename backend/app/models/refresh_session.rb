class RefreshSession < ApplicationRecord
  belongs_to :user

  validates :token_digest, presence: true, uniqueness: true
  validates :family_id, :expires_at, presence: true
end

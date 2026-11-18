class User < ApplicationRecord
  has_secure_password

  normalizes :email, with: -> (email) { email.strip.downcase }

  has_many :tasks, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :password_digest, presence: true
end

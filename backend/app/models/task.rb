class Task < ApplicationRecord
  belongs_to :user

  normalizes :title, with: -> (title) { title.strip }

  validates :title, presence: true, length: { minimum: 2, maximum: 120 }
  validates :description, length: { maximum: 2000 }, allow_blank: true
end

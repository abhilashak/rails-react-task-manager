class Task < ApplicationRecord
  belongs_to :user

  normalizes :title, with: -> (title) { title.strip }

  enum :status, {
    pending: 0,
    in_progress: 1,
    completed: 2
  }, validate: true

  validates :title, presence: true, length: { minimum: 2, maximum: 120 }
  validates :description, length: { maximum: 2000 }, allow_blank: true
end

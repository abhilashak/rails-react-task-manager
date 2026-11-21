# frozen_string_literal: true

module Authentication
  module Error
    USER_ERROR = "A persisted user is required"
    SECRET_MISSING = "JWT signing secret is missing"

    def secret_length(length)
      "JWT signing secret must be at least #{length} bytes"
    end
  end
end
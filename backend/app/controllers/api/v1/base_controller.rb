
class Api::V1::BaseController < ApplicationController
  before_action :authenticate_request!

  attr_reader :current_user

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  private

  def authenticate_request!
    authorization = request.headers["Authorization"].to_s

    match = authorization.match(/\ABearer\s+(\S+)\z/i)

    return render_unauthorized unless match

    payload = Authentication::TokenVerifier.verify(match[1])

    return render_unauthorized unless payload

    user_id = payload["sub"]

    unless user_id.is_a?(String) && user_id.match?(/\A[1-9]\d*\z/)
      return render_unauthorized
    end

    @current_user = User.find_by(id: user_id)

    render_unauthorized unless @current_user
  end

  def render_unauthorized
    render json: {
      errors: ["Unauthorized"]
    }, status: :unauthorized
  end

  def render_not_found
    render json: {
      errors: ["Resource not found"]
    }, status: :not_found
  end
end

class Api::V1::SessionsController < ApplicationController
  rate_limit to: 10,
             within: 3.minutes,
             only: :create,
             with: -> {
               render json: {
                 errors: ["Too many login attempts. Try again later."]
               }, status: :too_many_requests
             }

  def create
    email = login_params[:email].to_s.strip.downcase
    password = login_params[:password]
    user = User.find_by(email: email)

    unless password.present? && user&.authenticate(password)
      return render json: {
        errors: ["Invalid email or password"]
      }, status: :unauthorized
    end

    access_token = Authentication::AccessToken.issue(user)

    render json: SessionBlueprint.render_as_hash(
      user,
      root: :data,
      access_token: access_token,
      expires_in: Authentication::Base::ACCESS_TOKEN_TTL.to_i
    ), status: :ok
  end

  private

  def login_params
    params.require(:login).permit(:email, :password)
  end
end
class Api::V1::SessionsController < ApplicationController
  REFRESH_COOKIE = :refresh_token
  COOKIE_PATH = "/api/v1/auth"

  before_action :verify_frontend_origin!, only: %i[create refresh destroy]

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

  def refresh
    result = Authentication::RefreshToken.rotate(
      cookies[REFRESH_COOKIE]
    )

    unless result
      clear_refresh_cookie
      return render_invalid_credentials
    end

    access_token = Authentication::AccessToken.issue(result.user)

    set_refresh_cookie(result.token)

    render_session(result.user, access_token)
  end

  def destroy
    Authentication::RefreshToken.revoke(
      cookies[REFRESH_COOKIE]
    )

    clear_refresh_cookie

    head :no_content
  end

  private

  def login_params
    params.require(:login).permit(:email, :password)
  end

  def render_session(user, access_token)
    render json: SessionBlueprint.render_as_hash(
      user,
      root: :data,
      access_token: access_token,
      expires_in: Authentication::Base::ACCESS_TOKEN_TTL.to_i
    ), status: :ok
  end

  def render_invalid_credentials
    render json: {
      errors: ["Invalid email or password"]
    }, status: :unauthorized
  end

  def set_refresh_cookie(token)
    cookies[REFRESH_COOKIE] = {
      value: token,
      httponly: true,
      secure: Rails.env.production?,
      same_site: :lax,
      path: COOKIE_PATH,
      expires: Authentication::RefreshToken::TTL.from_now
    }
  end

  def clear_refresh_cookie
    cookies.delete(
      REFRESH_COOKIE,
      path: COOKIE_PATH,
      secure: Rails.env.production?,
      same_site: :lax
    )
  end

  # Cookie-authenticated endpoints need CSRF protection.
  # Restrict unsafe authentication requests to our trusted SPA origin.
  def verify_frontend_origin!
    expected_origin = ENV.fetch(
      "FRONTEND_ORIGIN",
      "http://localhost:5173"
    )

    return if request.headers["Origin"] == expected_origin

    render json: {
      errors: ["Untrusted request origin"]
    }, status: :forbidden
  end
end
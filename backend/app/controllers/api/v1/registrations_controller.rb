class Api::V1::RegistrationsController < ApplicationController
  rate_limit to: 10, within: 3.minutes, only: :create

  def create
    user = User.new(registration_params)

    if user.save
      render json: UserBlueprint.render_as_hash(user, root: :data), status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end

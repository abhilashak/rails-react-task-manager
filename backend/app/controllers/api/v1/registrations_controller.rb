class Api::V1::RegistrationsController < ApplicationController
  rate_limit to: 10, within: 3.minutes, only: :create

  def create
    user = User.new(register_params)

    if user.valid?
      user.save!

      render json: { 
        data: { id: user.id, email: user.email }, 
        status: :created
      }
    else
      render json: { errors: user.errors.full_messages, status: :unprocessable_entity }
    end
  end

  private

  def register_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end

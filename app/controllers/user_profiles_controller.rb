class UserProfilesController < ApplicationController
  before_action :is_authenticated
  before_action :is_allowed
  before_action :set_user_profile

  def show
    if @user_profile
      render json: {
        success: true,
        user_profile: @user_profile.as_json(include: :address)
      }, status: :ok
    else
      render json: {
        success: false,
        error: "Profile not found"
      }, status: :not_found
    end
  end

  private

  def set_user_profile
    @user_profile = current_user.user_profile
  end
end

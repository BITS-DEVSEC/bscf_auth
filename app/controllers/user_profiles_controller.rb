class UserProfilesController < ApplicationController
  before_action :is_authenticated
  before_action :is_allowed, only: [ :update_kyc ]
  before_action :set_user_profile, only: [ :show ]

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

  def update_kyc
    return render json: { success: false, error: "KYC status is required" },
                status: :unprocessable_entity unless params[:kyc_status].present?

    begin
      user_profile = Bscf::Core::UserProfile.find(params[:id])

      if user_profile.update(
        kyc_status: params[:kyc_status],
        verified_at: Time.current,
        verified_by: current_user
      )
        render json: { success: true, data: user_profile }
      else
        render json: { success: false, errors: user_profile.errors.full_messages },
               status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotFound
      render json: { success: false, error: "Profile not found" }, status: :not_found
    end
  end

  private

  def set_user_profile
    @user_profile = current_user.user_profile
  end

  def is_allowed
    user_role = current_user.user_roles.find { |ur| ur.role.name == "Admin" }
    render json: { success: false, error: "Not authorized" }, status: :unauthorized unless user_role
  end
end

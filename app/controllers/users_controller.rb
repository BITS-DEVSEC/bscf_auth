class UsersController < ApplicationController
  before_action :is_authenticated
  before_action :authenticate_admin
  include Common

  def self.inherited_methods
    %i[index show]
  end

  def by_role
    role = params[:role]
    unless [ "Driver", "User" ].include?(role)
      return render json: { success: false, error: "Invalid role specified" }, status: :bad_request
    end

    users = Bscf::Core::User.joins(:user_roles)
                           .joins(:roles)
                           .where(roles: { name: role })
                           .distinct

    users_with_info = users.map do |user|
      user_data = user.as_json
      if role == "Driver"
        user_data.merge!(vehicle: user.vehicle&.as_json)
      else # User role
        user_data.merge!(business: user.business&.as_json)
      end
      user_data
    end

    render json: {
      success: true,
      data: users_with_info
    }
  end

  private

  def authenticate_admin
    return render json: { success: false, error: "Unauthorized access" }, status: :unauthorized if current_user.nil?

    user_role = current_user.user_roles.find { |ur| ur.role.name == "Admin" }
    render json: { success: false, error: "Unauthorized access" }, status: :unauthorized unless user_role
  end
end

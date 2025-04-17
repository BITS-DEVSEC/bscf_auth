class UsersController < ApplicationController
  before_action :is_authenticated
  before_action :authenticate_admin

  def index
    users = Bscf::Core::User.all
    render json: {
      success: true,
      users: users.as_json(except: [ :password_digest ])
    }
  end

  private

  def authenticate_admin
    user_role = current_user.user_roles.find { |ur| ur.role.name == "Admin" }
    render json: { success: false, error: "Unauthorized access" }, status: :unauthorized unless user_role
  end
end

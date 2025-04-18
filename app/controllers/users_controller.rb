class UsersController < ApplicationController
  before_action :is_authenticated
  before_action :authenticate_admin
  include Common

  def self.inherited_methods
    %i[index show]
  end


  private

  def authenticate_admin
    user_role = current_user.user_roles.find { |ur| ur.role.name == "Admin" }
    render json: { success: false, error: "Unauthorized access" }, status: :unauthorized unless user_role
  end
end

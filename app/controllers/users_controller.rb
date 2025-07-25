class UsersController < ApplicationController
  before_action :is_authenticated
  before_action :authenticate_admin, except: [ :has_virtual_account ]
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

    render json: {
      success: true,
      data: ActiveModelSerializers::SerializableResource.new(users)
    }
  end

  def has_virtual_account
    has_account = Bscf::Core::VirtualAccount.exists?(user_id: current_user.id)

    render json: {
      success: true,
      has_virtual_account: has_account
    }
  end

  private

  def authenticate_admin
    return render json: { success: false, error: "Unauthorized access" }, status: :unauthorized if current_user.nil?

    user_role = current_user.user_roles.find { |ur| ur.role.name == "Admin" }
    render json: { success: false, error: "Unauthorized access" }, status: :unauthorized unless user_role
  end
end

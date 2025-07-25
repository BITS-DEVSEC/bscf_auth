class UsersController < ApplicationController
  before_action :is_authenticated
  include Common

  def self.inherited_methods
    %i[index show]
  end

  def index
    authorize Bscf::Core::User
    super
  end

  def show
    authorize @obj
    super
  end

  def by_role
    authorize Bscf::Core::User
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
    authorize Bscf::Core::User
    has_account = Bscf::Core::VirtualAccount.exists?(user_id: current_user.id)

    render json: {
      success: true,
      has_virtual_account: has_account
    }
  end

  private

  def model_params
    params.require(:user).permit(:first_name, :middle_name, :last_name, :email, :phone_number, :password)
  end
end

class UserRolesController < ApplicationController
  before_action :is_authenticated

  def assign_driver
    return render json: { success: false, error: "User ID is required" }, status: :unprocessable_entity unless params[:user_id].present?

    begin
      user_to_assign = Bscf::Core::User.find(params[:user_id])
      driver_role = Bscf::Core::Role.find_by(name: "Driver")

      unless driver_role
        return render json: { success: false, error: "Driver role not found." }, status: :not_found
      end

      existing_assignment = Bscf::Core::UserRole.find_by(user: user_to_assign, role: driver_role)
      if existing_assignment
        return render json: { success: true, message: "User is already assigned as a Driver.", data: existing_assignment.as_json(include: [ :user, :role ]) }
      end

      user_role_assignment = Bscf::Core::UserRole.new(user: user_to_assign, role: driver_role)

      if user_role_assignment.save
        render json: { success: true, data: user_role_assignment.as_json(include: [ :user, :role ]) }
      else
        render json: { success: false, errors: user_role_assignment.errors.full_messages }, status: :unprocessable_entity
      end

    rescue ActiveRecord::RecordNotFound
      render json: { success: false, error: "User not found with ID: #{params[:user_id]}" }, status: :not_found
    end
  end
end

class AuthController < ApplicationController
  before_action :token_service

  def signup
    ActiveRecord::Base.transaction do
      @address = Bscf::Core::Address.new(address_params)

      if @address.save
        @user = Bscf::Core::User.new(user_params)

        if @user.save
          @user_profile = Bscf::Core::UserProfile.new(user_profile_params)
          @user_profile.user = @user
          @user_profile.address = @address

          if @user_profile.save
            # Assign default user role
            user_role = Bscf::Core::Role.find_or_create_by!(name: "User")
            Bscf::Core::UserRole.find_or_create_by!(user: @user, role: user_role)

            @business = Bscf::Core::Business.new(
              user: @user,
              business_name: signup_params[:business_name],
              tin_number: signup_params[:tin_number],
              business_type: signup_params[:business_type]
            )

            if @business.save
              render json: {
                success: true,
                user: @user.as_json(except: [:password_digest]),
                user_profile: @user_profile,
                business: @business,
                address: @address
              }, status: :created
              return
            else
              render json: { errors: @business.errors.full_messages }, status: :unprocessable_entity
              raise ActiveRecord::Rollback
            end
          else
            render json: { errors: @user_profile.errors.full_messages }, status: :unprocessable_entity
            raise ActiveRecord::Rollback
          end
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
          raise ActiveRecord::Rollback
        end
      else
        render json: { errors: @address.errors.full_messages }, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
    end
  end

  def login
    user = Bscf::Core::User
           .includes(user_roles: :role, user_profile: :address)
           .find_by(phone_number: auth_params[:phone_number])

    return render json: { success: false, error: "User doesn't exist" }, status: :unauthorized unless user
    return render json: { success: false, error: "Invalid phone number or password" }, status: :unauthorized unless user.authenticate(auth_params[:password])


    user_profile = user.user_profile
    return render json: { success: false, error: "Profile not complete" }, status: :unauthorized unless user_profile

    token = @token_service.encode({
      user: user.as_json(except: ["password_digest", "created_at", "updated_at"]),
      user_profile: user_profile.as_json
    })

    render json: {
      success: true,
      token: token,
      user: user.as_json(except: [:password_digest]),
      user_profile: user_profile.as_json
    }
  end

  def admin_login
    user = Bscf::Core::User.includes(user_roles: :role).find_by(phone_number: auth_params[:phone_number])

    return render json: { success: false, error: "User doesn't exist" }, status: :unauthorized unless user
    return render json: { success: false, error: "Invalid phone number or password" }, status: :unauthorized unless user.authenticate(auth_params[:password])

    user_role = user.user_roles.find { |ur| ur.role.name == "Admin" }
    return render json: { success: false, error: "Unauthorized access" }, status: :unauthorized unless user_role

    token = @token_service.encode({
      user: user.as_json(except: ["password_digest", "created_at", "updated_at"]),
      role: user_role.role.name
    })

    render json: {
      success: true,
      token: token,
      user: user.as_json(except: [:password_digest]),
      role: user_role.role.name
    }
  end


  private

  def token_service
    @token_service ||= Bscf::Core::TokenService.new
  end

  def auth_params
    params.require(:auth).permit(:phone_number, :password, :password_confirmation, :reset_password_token, :new_password)
  end

  def signup_params
    params.require(:user).permit(
      :first_name, :middle_name, :last_name, :password,
      :phone_number, :business_name, :tin_number, :business_type,
      :date_of_birth, :nationality, :occupation, :source_of_funds, :kyc_status,
      :gender, :verified_at, :verified_by_id, :email, :fayda_id
    )
  end

  def user_params
    signup_params.slice(
      :first_name, :middle_name, :last_name,
      :password, :phone_number, :email
    )
  end

  def user_profile_params
    signup_params.slice(
      :date_of_birth, :nationality, :occupation,
      :source_of_funds, :kyc_status, :gender,
      :verified_at, :verified_by_id, :fayda_id
    )
  end

  def address_params
      params.require(:address).permit(
          :city,
          :sub_city,
          :woreda,
          :latitude,
          :longitude
      )
  end
end

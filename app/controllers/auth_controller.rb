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

            user_role = Bscf::Core::Role.find_or_create_by!(name: "User")
            Bscf::Core::UserRole.find_or_create_by!(user: @user, role: user_role)
            create_virtual_account(@user)

            if signup_params[:business_name].present?
              @business = Bscf::Core::Business.new(
                user: @user,
                business_name: signup_params[:business_name],
                tin_number: signup_params[:tin_number],
                business_type: signup_params[:business_type]
              )

              if @business.save
                render json: {
                  success: true,
                  user: @user.as_json(except: [ :password_digest ]),
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
              render json: {
                success: true,
                user: @user.as_json(except: [ :password_digest ]),
                user_profile: @user_profile,
                address: @address
              }, status: :created
              return
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
      user: user.as_json(except: [ "password_digest", "created_at", "updated_at" ]),
      user_profile: user_profile.as_json
    })

    render json: {
      success: true,
      token: token,
      user: user.as_json(except: [ :password_digest ]),
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
      user: user.as_json(except: [ "password_digest", "created_at", "updated_at" ]),
      role: user_role.role.name
    })

    render json: {
      success: true,
      token: token,
      user: user.as_json(except: [ :password_digest ]),
      role: user_role.role.name
    }
  end

  def driver_signup
    ActiveRecord::Base.transaction do
      @user = Bscf::Core::User.new(driver_signup_user_core_params) # Changed from driver_user_params

      if @user.save
        @address = Bscf::Core::Address.new(address_params) # Assuming address_params can be reused

        if @address.save
          @user_profile = Bscf::Core::UserProfile.new(driver_signup_user_profile_params)
          @user_profile.user = @user
          @user_profile.address = @address

          if @user_profile.save
            @vehicle = Bscf::Core::Vehicle.new(vehicle_params)
            @vehicle.driver = @user

            if @vehicle.save
              driver_role = Bscf::Core::Role.find_by(name: "Driver")

              unless driver_role
                driver_role = Bscf::Core::Role.create!(name: "Driver") if driver_role.nil?
                if driver_role.nil? || driver_role.invalid?
                   render json: { success: false, error: "Driver role could not be found or created." }, status: :internal_server_error
                   raise ActiveRecord::Rollback
                end
              end

              @user_role = Bscf::Core::UserRole.new(user: @user, role: driver_role)

              if @user_role.save
                create_virtual_account(@user)
                render json: {
                  success: true,
                  user: @user.as_json(except: [ :password_digest ]),
                  user_profile: @user_profile.as_json,
                  address: @address.as_json,
                  vehicle: @vehicle.as_json,
                  role: driver_role.as_json
                }, status: :created
              else
                render json: { success: false, errors: @user_role.errors.full_messages }, status: :unprocessable_entity
                raise ActiveRecord::Rollback
              end
            else
              render json: { success: false, errors: @vehicle.errors.full_messages }, status: :unprocessable_entity
              raise ActiveRecord::Rollback
            end
          else
            render json: { success: false, errors: @user_profile.errors.full_messages }, status: :unprocessable_entity
            raise ActiveRecord::Rollback
          end
        else
          render json: { success: false, errors: @address.errors.full_messages }, status: :unprocessable_entity
          raise ActiveRecord::Rollback
        end
      else
        render json: { success: false, errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: { success: false, errors: e.record.errors.full_messages }, status: :unprocessable_entity
  rescue StandardError => e
    render json: { success: false, error: "An unexpected error occurred: #{e.message}" }, status: :internal_server_error
    raise ActiveRecord::Rollback if ActiveRecord::Base.connection.transaction_open? # Ensure rollback on unexpected errors
  end


  private

  def token_service
    @token_service ||= Bscf::Core::TokenService.new
  end

  def create_virtual_account(user)
    Bscf::Core::VirtualAccount.create!(
      user: user,
      branch_code: "VA#{SecureRandom.hex(4).upcase}",
      product_scheme: "SAVINGS",
      voucher_type: "REGULAR",
      balance: 0.0,
      interest_rate: 2.5,
      interest_type: :simple,
      status: :pending,
      cbs_account_number: "CBS#{SecureRandom.hex(4).upcase}"
    )
  end

  def auth_params
    params.require(:auth).permit(:phone_number, :password, :password_confirmation, :reset_password_token, :new_password)
  end

  def signup_params
    params.require(:user).permit(
      :first_name, :middle_name, :last_name, :password,
      :phone_number, :business_name, :tin_number, :business_type,
      :date_of_birth, :nationality, :occupation, :source_of_funds, :kyc_status,
      :gender, :verified_at, :verified_by_id, :fayda_id
    )
  end

  def user_params
    signup_params.slice(
      :first_name, :middle_name, :last_name, :password, :phone_number
    )
  end

  def user_profile_params
    signup_params.slice(
      :date_of_birth, :nationality, :occupation, :source_of_funds, :kyc_status,
      :gender, :verified_at, :verified_by_id, :fayda_id
    )
  end

  def address_params
    params.require(:address).permit(:city, :sub_city, :woreda, :latitude, :longitude, :house_number)
  end

  # Replaces the old driver_user_params
  def driver_signup_user_core_params
    params.require(:user).permit(
      :first_name, :middle_name, :last_name, :phone_number, :password, :password_confirmation
    )
  end

  # New params method for driver's user profile information
  # Assumes profile fields are nested under params[:user]
  def driver_signup_user_profile_params
    params.require(:user).permit(
      :date_of_birth, :nationality, :occupation, :source_of_funds,
      :gender, :fayda_id # fayda_id is optional as per schema
    )
  end

  def vehicle_params
    params.require(:vehicle).permit(
      :plate_number, :vehicle_type, :brand, :model, :year, :color
    )
  end
end

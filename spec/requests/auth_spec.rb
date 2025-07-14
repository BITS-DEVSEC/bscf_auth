require 'rails_helper'

RSpec.describe "Auth", type: :request do
  describe "POST /auth/signup" do
    let(:valid_params) do
      {
        user: {
          first_name: Faker::Name.first_name,
          middle_name: Faker::Name.middle_name,
          last_name: Faker::Name.last_name,
          phone_number: "+251#{Faker::Number.number(digits: 9)}",
          password: "123456",
          business_name: Faker::Company.name,
          tin_number: Faker::Number.number(digits: 10).to_s,
          business_type: "retailer",
          date_of_birth: Date.today.strftime("%Y-%m-%d"),
          nationality: "Ethiopian",
          occupation: "Business Owner",
          source_of_funds: "Business",
          gender: "male",
          fayda_id: Faker::Number.number(digits: 10).to_s
        },
        address: {
          city: "Addis Ababa",
          sub_city: "Bole",
          woreda: "03",
          latitude: "9.0222",
          longitude: "38.7468"
        }
      }
    end
    it "creates a new user successfully" do
      post "/auth/signup", params: valid_params, as: :json
      result = JSON.parse(response.body)
      expect(response).to have_http_status(:created)
      expect(result["success"]).to be true
      expect(result["user"]["phone_number"]).to eq(valid_params[:user][:phone_number])
      expect(result["business"]["business_name"]).to eq(valid_params[:user][:business_name])
      expect(result["address"]["city"]).to eq(valid_params[:address][:city])
      expect(result["user_profile"]).to be_present
      expect(result["user_profile"]["date_of_birth"].to_date).to eq(valid_params[:user][:date_of_birth].to_date)
      expect(result["user_profile"]["gender"]).to eq(valid_params[:user][:gender])
      created_user = Bscf::Core::User.find_by(phone_number: valid_params[:user][:phone_number])
      expect(Bscf::Core::VirtualAccount.find_by(user_id: created_user.id)).to be_present
    end

    it "fails with invalid parameters" do
      invalid_params = valid_params
      invalid_params[:user][:phone_number] = nil

      post "/auth/signup", params: invalid_params, as: :json

      result = JSON.parse(response.body)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(result["errors"]).to be_present
    end
  end

  describe "POST /auth/login" do
    let!(:user) do
      user = create(:user, phone_number: "251911223344", password: "123456")
      create(:user_profile, user: user)
      user
    end

    it "logs in successfully with valid credentials" do
      params = {
        auth: {
          phone_number: "251911223344",
          password: "123456"
        }
      }

      post "/auth/login", params: params, as: :json # Added as: :json

      result = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(result["success"]).to be true
      expect(result["token"]).to be_present
      expect(result["user"]["phone_number"]).to eq("251911223344")
      expect(result["user_profile"]).to be_present
    end

    it "fails with invalid password" do
      params = {
        auth: {
          phone_number: "251911223344",
          password: "654321"
        }
      }

      post "/auth/login", params: params, as: :json

      result = JSON(response.body)
      expect(response).to have_http_status(:unauthorized)
      expect(result["error"]).to eq("Invalid phone number or password")
    end

    it "fails with non-existent user" do
      params = {
        auth: {
          phone_number: "251999999999",
          password: "123456"
        }
      }

      post "/auth/login", params: params, as: :json

      result = JSON.parse(response.body)
      expect(response).to have_http_status(:unauthorized)
      expect(result["error"]).to eq("User doesn't exist")
    end
  end

  describe "POST /auth/admin/login" do
    let!(:admin_user) do
      user = create(:user, phone_number: "251911223344", password: "123456")
      admin_role = create(:role, name: "Admin")
      create(:user_role, user: user, role: admin_role)
      user
    end

    it "logs in admin successfully" do
      params = {
        auth: {
          phone_number: "251911223344",
          password: "123456"
        }
      }

      post "/auth/admin/login", params: params, as: :json # Added as: :json

      result = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(result["success"]).to be true
      expect(result["token"]).to be_present
      expect(result["role"]).to eq("Admin")
    end

    it "fails for non-admin users" do
      regular_user = create(:user, phone_number: "251922334455", password: "123456")
      user_role = create(:role, name: "User") # Ensure "User" role exists for this test
      create(:user_role, user: regular_user, role: user_role)

      params = {
        auth: {
          phone_number: "251922334455",
          password: "123456"
        }
      }

      post "/auth/admin/login", params: params, as: :json # Added as: :json

      result = JSON.parse(response.body)
      expect(response).to have_http_status(:unauthorized)
      expect(result["error"]).to eq("Unauthorized access")
    end
  end

  describe "POST /auth/driver/signup" do
    let!(:driver_role) { create(:role, name: "Driver") } # Ensure Driver role exists

    let(:valid_driver_params) do
      {
        user: {
          first_name: Faker::Name.first_name,
          middle_name: Faker::Name.middle_name,
          last_name: Faker::Name.last_name,
          phone_number: "+251#{Faker::Number.number(digits: 9)}",
          password: "123456",
          # Add user_profile attributes for driver
          date_of_birth: Faker::Date.birthday(min_age: 18, max_age: 65).strftime("%Y-%m-%d"),
          gender: [ "male", "female" ].sample,
          nationality: "Ethiopian",
          occupation: "Driver",
          source_of_funds: "Salary",
          fayda_id: Faker::Number.number(digits: 10).to_s
        },
        vehicle: {
          plate_number: "AA-#{Faker::Number.number(digits: 5)}",
          vehicle_type: "Sedan",
          brand: Faker::Vehicle.make,
          model: Faker::Vehicle.model,
          year: Faker::Vehicle.year.to_i, # Ensure year is an integer
          color: Faker::Vehicle.color
        },
        # Add address attributes for driver, assuming it's directly under params for now
        # or adjust if it should be nested under user or vehicle
        address: {
          city: "Addis Ababa",
          sub_city: "Bole",
          woreda: "03",
          latitude: "9.0222",
          longitude: "38.7468"
        }
      }
    end

    context "with valid parameters" do
      it "creates a new driver user, user_profile, vehicle, and assigns driver role successfully" do
        post "/auth/driver/signup", params: valid_driver_params, as: :json

        result = JSON.parse(response.body)

        expect(response).to have_http_status(:created)
        expect(result["success"]).to be true
        expect(result["user"]["phone_number"]).to eq(valid_driver_params[:user][:phone_number])
        expect(result["user_profile"]).to be_present
        expect(result["user_profile"]["gender"]).to eq(valid_driver_params[:user][:gender])
        expect(result["user_profile"]["occupation"]).to eq("Driver")
        expect(result["vehicle"]["plate_number"]).to eq(valid_driver_params[:vehicle][:plate_number])
        expect(result["role"]["name"]).to eq("Driver")
        expect(result["address"]["city"]).to eq(valid_driver_params[:address][:city])


        created_user = Bscf::Core::User.find_by(phone_number: valid_driver_params[:user][:phone_number])
        expect(created_user).to be_present
        expect(created_user.user_profile).to be_present
        expect(created_user.user_profile.address).to be_present
        expect(Bscf::Core::VirtualAccount.find_by(user_id: created_user.id)).to be_present
      end
    end

    context "with invalid user parameters" do
      it "fails to create a driver if user phone_number is missing" do
        invalid_params = valid_driver_params.deep_dup
        invalid_params[:user][:phone_number] = nil

        post "/auth/driver/signup", params: invalid_params, as: :json
        result = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(result["success"]).to be false
        expect(result["errors"]).to include("Phone number can't be blank")
      end
    end
  end
end

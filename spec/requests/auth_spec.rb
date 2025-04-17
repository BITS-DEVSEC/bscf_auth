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
      post "/auth/signup", params: valid_params
      result = JSON.parse(response.body)
      expect(response).to have_http_status(:created)
      expect(result["success"]).to be true
      expect(result["user"]["phone_number"]).to eq(valid_params[:user][:phone_number])
      expect(result["business"]["business_name"]).to eq(valid_params[:user][:business_name])
      expect(result["address"]["city"]).to eq(valid_params[:address][:city])
    end

    it "fails with invalid parameters" do
      invalid_params = valid_params
      invalid_params[:user][:phone_number] = nil

      post "/auth/signup", params: invalid_params

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

      post "/auth/login", params: params

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

      post "/auth/login", params: params

      result = JSON.parse(response.body)
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

      post "/auth/login", params: params

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

      post "/auth/admin/login", params: params

      result = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(result["success"]).to be true
      expect(result["token"]).to be_present
      expect(result["role"]).to eq("Admin")
    end

    it "fails for non-admin users" do
      regular_user = create(:user, phone_number: "251922334455", password: "123456")
      user_role = create(:role, name: "User")
      create(:user_role, user: regular_user, role: user_role)

      params = {
        auth: {
          phone_number: "251922334455",
          password: "123456"
        }
      }

      post "/auth/admin/login", params: params

      result = JSON.parse(response.body)
      expect(response).to have_http_status(:unauthorized)
      expect(result["error"]).to eq("Unauthorized access")
    end
  end
end

require 'rails_helper'

RSpec.describe "Users", type: :request do
  let(:token_service) { Bscf::Core::TokenService.new }
  let(:admin_user) { create(:user) }
  let(:admin_role) { create(:role, name: "Admin") }
  let!(:admin_user_role) { create(:user_role, user: admin_user, role: admin_role) }

  let(:token) do
    token_service.encode({
      user: admin_user.as_json(except: [ "password_digest", "created_at", "updated_at" ])
    })
  end

  let(:headers) do
    {
      "Authorization" => "Bearer #{token}"
    }
  end

  describe "GET /users" do
    it "lists all users when admin authenticated" do
      create_list(:user, 3)

      get users_url, headers: headers

      result = JSON(response.body)
      expect(result["success"]).to be_truthy
      expect(result["data"].count).to eq(4)
      expect(result["data"].first.keys).to include("id", "first_name", "last_name", "email", "phone_number", "user_profile", "roles")
    end

    it "returns unauthorized for non-admin user" do
      user = create(:user)
      user_role = create(:role, name: "User")
      create(:user_role, user: user, role: user_role)

      non_admin_token = token_service.encode({
        user: user.as_json(except: [ "password_digest", "created_at", "updated_at" ])
      })

      get users_url, headers: { "Authorization" => "Bearer #{non_admin_token}" }

      result = JSON(response.body)
      expect(result["success"]).to be_falsey
      expect(result["error"]).to eq("Unauthorized access")
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /users/:id" do
    it "shows user details with associations" do
      target_user = create(:user)
      user_profile = create(:user_profile, user: target_user)
      user_role = create(:role, name: "User")
      create(:user_role, user: target_user, role: user_role)

      get user_url(target_user), headers: headers

      result = JSON(response.body)
      expect(result["success"]).to be_truthy
      expect(result["data"]["id"]).to eq(target_user.id)
      expect(result["data"]["user_profile"]).to be_present
      expect(result["data"]["roles"]).to be_present
      expect(result["data"]["user_roles"]).to be_present
    end

    it "returns unauthorized for non-admin user" do
      user = create(:user)
      user_role = create(:role, name: "User")
      create(:user_role, user: user, role: user_role)

      non_admin_token = token_service.encode({
        user: user.as_json(except: [ "password_digest", "created_at", "updated_at" ])
      })

      get user_url(user), headers: { "Authorization" => "Bearer #{non_admin_token}" }

      result = JSON(response.body)
      expect(result["success"]).to be_falsey
      expect(result["error"]).to eq("Unauthorized access")
      expect(response).to have_http_status(:unauthorized)
    end
  end
end

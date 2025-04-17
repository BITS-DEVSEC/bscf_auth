require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe "GET /users" do
    let(:token_service) { Bscf::Core::TokenService.new }

    context "when admin user is authenticated" do
      let!(:admin_user) { create(:user) }
      let!(:admin_role) { create(:role, name: "Admin") }
      let!(:admin_user_role) { create(:user_role, user: admin_user, role: admin_role) }
      let!(:regular_users) { create_list(:user, 3) }

      let(:token) do
        token_service.encode({
          user: admin_user.as_json(except: [ "password_digest", "created_at", "updated_at" ])
        })
      end

      it "returns list of all users" do
        get "/users", headers: { "Authorization" => "Bearer #{token}" }

        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        expect(json["success"]).to be true
        expect(json["users"].length).to eq(4) # admin + 3 regular users
        expect(json["users"].first.keys).not_to include("password_digest")
      end
    end

    context "when non-admin user is authenticated" do
      let!(:user) { create(:user) }
      let!(:user_role) { create(:role, name: "User") }
      let!(:user_user_role) { create(:user_role, user: user, role: user_role) }

      let(:token) do
        token_service.encode({
          user: user.as_json(except: [ "password_digest", "created_at", "updated_at" ])
        })
      end

      it "returns unauthorized" do
        get "/users", headers: { "Authorization" => "Bearer #{token}" }

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json["success"]).to be false
        expect(json["error"]).to eq("Unauthorized access")
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized" do
        get "/users"

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Not authenticated")
      end
    end
  end
end

require 'rails_helper'

RSpec.describe "UserProfiles", type: :request do
  describe "GET /user_profile" do
    let(:token_service) { Bscf::Core::TokenService.new }

    context "when user is authenticated" do
      let!(:user) { create(:user) }
      let!(:address) { create(:address) }
      let!(:user_profile) { create(:user_profile, user: user, address: address) }
      let!(:user_role) { create(:role, name: "User") }
      let!(:user_user_role) { create(:user_role, user: user, role: user_role) }

      let(:token) do
        token_service.encode({
          user: user.as_json(except: [ "password_digest", "created_at", "updated_at" ]),
          user_profile: user_profile.as_json
        })
      end

      it "returns user profile with address" do
        get "/user_profile", headers: { "Authorization" => "Bearer #{token}" }
        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        expect(json["success"]).to be true
        expect(json["user_profile"]["id"]).to eq(user_profile.id)
        expect(json["user_profile"]["address"]["id"]).to eq(address.id)
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized" do
        get "/user_profile"

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Not authenticated")
      end
    end

    context "when user profile doesn't exist" do
      let!(:user) { create(:user) }
      let!(:user_role) { create(:role, name: "User") }
      let!(:user_user_role) { create(:user_role, user: user, role: user_role) }

      let(:token) do
        token_service.encode({
          user: user.as_json(except: [ "password_digest", "created_at", "updated_at" ])
        })
      end

      it "returns not found" do
        get "/user_profile", headers: { "Authorization" => "Bearer #{token}" }

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json["success"]).to be false
        expect(json["error"]).to eq("Profile not found")
      end
    end
  end
end

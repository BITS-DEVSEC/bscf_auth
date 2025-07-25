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

  describe "PUT /user_profiles/:id/update_kyc" do
    let(:token_service) { Bscf::Core::TokenService.new }

    context "when admin user is authenticated" do
      let!(:admin_user) { create(:user) }
      let!(:admin_role) { create(:role, name: "Admin") }
      let!(:admin_user_role) { create(:user_role, user: admin_user, role: admin_role) }
      let!(:target_user) { create(:user) }
      let!(:user_profile) { create(:user_profile, user: target_user) }

      let(:token) do
        token_service.encode({
          user: admin_user.as_json(except: [ "password_digest", "created_at", "updated_at" ])
        })
      end

      it "updates kyc status successfully" do
        params = {
          kyc_status: "approved"
        }

        put update_kyc_user_profile_url(user_profile),
            params: params,
            headers: { "Authorization" => "Bearer #{token}" }

        result = JSON(response.body)
        expect(result["success"]).to be_truthy
        expect(result["data"]["kyc_status"]).to eq("approved")
        expect(result["data"]["verified_by_id"]).to eq(admin_user.id)
        expect(result["data"]["verified_at"]).not_to be_nil
      end

      it "returns error when kyc_status is missing" do
        put update_kyc_user_profile_url(user_profile),
            params: {},
            headers: { "Authorization" => "Bearer #{token}" }

        result = JSON(response.body)
        expect(result["success"]).to be_falsey
        expect(result["error"]).to eq("KYC status is required")
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns error when user profile doesn't exist" do
        params = {
          kyc_status: "approved"
        }

        put update_kyc_user_profile_url(0),
            params: params,
            headers: { "Authorization" => "Bearer #{token}" }

        result = JSON(response.body)
        expect(result["success"]).to be_falsey
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when non-admin user is authenticated" do
      let!(:user) { create(:user) }
      let!(:user_role) { create(:role, name: "User") }
      let!(:user_user_role) { create(:user_role, user: user, role: user_role) }
      let!(:user_profile) { create(:user_profile, user: user) }

      let(:token) do
        token_service.encode({
          user: user.as_json(except: [ "password_digest", "created_at", "updated_at" ])
        })
      end

      it "returns unauthorized" do
        params = {
          kyc_status: "approved"
        }

        put update_kyc_user_profile_url(user_profile),
            params: params,
            headers: { "Authorization" => "Bearer #{token}" }

        result = JSON(response.body)
        expect(result["success"]).to be_falsey
        expect(result["error"]).to eq("You are not authorized to perform this action.")
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is not authenticated" do
      let!(:user_profile) { create(:user_profile) }

      it "returns unauthorized" do
        params = {
          kyc_status: "approved"
        }

        put update_kyc_user_profile_url(user_profile), params: params

        result = JSON(response.body)
        expect(result["error"]).to eq("Not authenticated")
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end

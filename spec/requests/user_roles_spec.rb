require 'rails_helper'

RSpec.describe "UserRoles", type: :request do
  let(:token_service) { Bscf::Core::TokenService.new }
  let!(:acting_user) { create(:user) } # Can be any authenticated user
  let!(:user_role) { create(:role, name: "User") } # A generic role for the acting_user
  let!(:acting_user_role_assignment) { create(:user_role, user: acting_user, role: user_role) }

  let(:headers) do
    token = token_service.encode({ user: acting_user.as_json(except: [ "password_digest", "created_at", "updated_at" ]) })
    { "Authorization" => "Bearer #{token}" }
  end

  describe "POST /user_roles/assign_driver" do
    let!(:driver_role) { create(:role, name: "Driver") }
    let!(:user_to_assign) { create(:user) }

    context "with valid parameters and authentication" do
      it "assigns the Driver role to the user successfully" do
        post assign_driver_user_roles_url, params: { user_id: user_to_assign.id }, headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["success"]).to be true
        expect(json["data"]["user"]["id"]).to eq(user_to_assign.id)
        expect(json["data"]["role"]["name"]).to eq("Driver")
        expect(Bscf::Core::UserRole.find_by(user: user_to_assign, role: driver_role)).to be_present
      end

      it "returns a success message if the user is already a Driver" do
        create(:user_role, user: user_to_assign, role: driver_role) # Pre-assign the role

        post assign_driver_user_roles_url, params: { user_id: user_to_assign.id }, headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["success"]).to be true
        expect(json["message"]).to eq("User is already assigned as a Driver.")
        expect(json["data"]["user"]["id"]).to eq(user_to_assign.id)
        expect(json["data"]["role"]["name"]).to eq("Driver")
      end
    end

    context "when Driver role does not exist" do
      before do
        driver_role.destroy # Ensure the Driver role is not present
      end

      it "returns an error" do
        post assign_driver_user_roles_url, params: { user_id: user_to_assign.id }, headers: headers

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json["success"]).to be false
        expect(json["error"]).to eq("Driver role not found.")
      end
    end

    context "with invalid parameters" do
      it "returns an error if user_id is missing" do
        post assign_driver_user_roles_url, params: {}, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["success"]).to be false
        expect(json["error"]).to eq("User ID is required")
      end

      it "returns an error if the target user is not found" do
        post assign_driver_user_roles_url, params: { user_id: 0 }, headers: headers # Non-existent user_id

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json["success"]).to be false
        expect(json["error"]).to eq("User not found with ID: 0")
      end
    end

    context "without authentication" do
      it "returns an unauthorized error" do
        post assign_driver_user_roles_url, params: { user_id: user_to_assign.id } # No headers

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Not authenticated")
      end
    end
  end
end

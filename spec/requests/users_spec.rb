require "rails_helper"

RSpec.describe "Users", type: :request do
  let!(:admin_user) { create(:user) }
  let!(:driver_role) { create(:role, name: "Driver") }
  let!(:user_role) { create(:role, name: "User") }
  let!(:admin_role) { create(:role, name: "Admin") }

  let(:headers) do
    create(:user_role, user: admin_user, role: admin_role)
    token = Bscf::Core::TokenService.new.encode(
      user: admin_user.as_json(except: [ "password_digest", "created_at", "updated_at" ])
    )
    { Authorization: "Bearer #{token}" }
  end

  describe "GET /users/by_role" do
    before do
      # Create test users
      @drivers = create_list(:user, 3)
      @regular_users = create_list(:user, 2)

      # Assign roles
      @drivers.each { |driver| create(:user_role, user: driver, role: driver_role) }
      @regular_users.each { |user| create(:user_role, user: user, role: user_role) }
    end

    it "returns users with Driver role" do
      get "/users/by_role", params: { role: "Driver" }, headers: headers

      result = JSON(response.body)
      expect(result["success"]).to be_truthy
      expect(result["data"].count).to eq 3
      expect(result["data"].first.keys).to include("id", "first_name", "middle_name", "last_name", "email", "phone_number", "vehicle")
      expect(response).to have_http_status(:ok)
    end

    it "returns users with User role" do
      get "/users/by_role", params: { role: "User" }, headers: headers

      result = JSON(response.body)
      expect(result["success"]).to be_truthy
      expect(result["data"].count).to eq 2
      expect(result["data"].first.keys).to include("id", "first_name", "middle_name", "last_name", "email", "phone_number", "business")
      expect(response).to have_http_status(:ok)
    end

    it "returns error for invalid role" do
      get "/users/by_role", params: { role: "InvalidRole" }, headers: headers

      result = JSON(response.body)
      expect(result["success"]).to be_falsey
      expect(result["error"]).to eq "Invalid role specified"
      expect(response).to have_http_status(:bad_request)
    end

    it "returns unauthorized for non-admin users" do
      regular_user = create(:user)
      regular_token = Bscf::Core::TokenService.new.encode(
        user: regular_user.as_json(except: [ "password_digest", "created_at", "updated_at" ])
      )

      get "/users/by_role",
          params: { role: "Driver" },
          headers: { Authorization: "Bearer #{regular_token}" }

      expect(response).to have_http_status(:unauthorized)
      result = JSON(response.body)
      expect(result["success"]).to be_falsey
      expect(result["error"]).to eq "Unauthorized access"
    end
  end
end

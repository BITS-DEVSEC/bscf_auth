class UserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :middle_name, :last_name, :email, :phone_number
  has_one :user_profile
  has_many :user_roles
  has_many :roles, through: :user_roles
end

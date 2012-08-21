class User
  include MongoMapper::Document


  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :validatable, :omniauthable

  key :email, String
  key :first_name, String
  key :last_name, String
  key :encrypted_password, String

  timestamps!
end
  
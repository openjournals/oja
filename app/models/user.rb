class User
  include MongoMapper::Document
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :validatable, :omniauthable

  key :email, String
  key :first_name, String
  key :last_name, String
  key :encrypted_password, String
  key :roles, Array
  key :research_areas, Array

  has_many :papers 

  timestamps!

  def is_editor
    @roles.include? 'editor'
  end

  def is_reviewer
    @roles.include? 'reviewer'
  end

  def role_on_paper(paper)
    if  paper.submiting_authour == self
      role = 'submitting_author'
    elsif paper.reviewer = self 
      role = 'reviewer'
    elsif paper.authors.include? self 
      role = 'authour'
    else 
      role=nil
    end
  end
end
  
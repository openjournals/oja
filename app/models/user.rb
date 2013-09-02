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

  scope :reviewers, :roles => 'reviewer'

  timestamps!
  
  def admin?
    @roles.include? 'admin'
  end

  def is_editor?
    @roles.include? 'editor'
  end

  def greatest_role 
    role = "author"
    ["editor","reviewer","author"].reverse.each do |_role|
      role = _role if roles.include? _role
    end
    role 
  end

  def full_name 
    "#{first_name} #{last_name}"
  end

  def is_reviewer?
    @roles.include? 'reviewer'
  end

  def is_author?
    @roles.include? 'author'
  end

  def make_editor
    self.add_to_set :roles => "editor"
  end

  def make_reviewer
    self.add_to_set :roles => "reviewer"
  end

  def revoke_editor
    self.pull :roles => "editor"
  end

  def revoke_reviewer
    self.pull :roles => "reviewer"
  end

  def assign_paper(paper)
    if is_reviewer
      paper.set({:reviewer_id => id, state: "under_review"})
    end
  end

  def papers_for_review
    Paper.where({:reviewer_id=> id, :state=>"under_review"})
  end

  def accepted_papers 
    Paper.where({:reviewer_id => id, :state=>"accepted"})
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
  
class Paper 
  include MongoMapper::Document
  key :title, String
  key :github_address, String
  key :version, Integer, :default => 1
  key :current_review_number, Integer, :default => 1
  key :state, String
  key :category, String
  key :arxiv_id, String
  key :author_ids, Array
  key :pdf_url, String
  key :pngs_generated, Boolean
  key :authors, Array
  key :submitted_at, DateTime
  key :submitting_author_id, ObjectId
  key :reviewer_id, ObjectId 

  scope :in_review, :state => 'under_review'
  scope :submitted, :state => 'submitted'
  scope :accepted, :state => 'accepted'


  # has_many   :authors, :in => :author_ids
  # belongs_to :reviewer

  has_many :tasks

  after_create :pull_arxiv_details  

  state_machine :initial => :submitted do 
    state :submitted
    state :under_review
    state :accepted

    after_transition :on => :accept, :do => :resolve_all_issues


    event :accept do
      transition all => :accepted
    end
    event :assigned do
      transition :submitted => :under_review
    end
  end

  def as_json(options)
    super((options || { }).merge({
        :methods => [:pretty_submission_date, :pretty_author, :pretty_status]
    }))
  end

  def update_state(state)
    if Paper.allowed_states.include? status
      state = state
      save
    end 
  end

  def self.allowed_states
    User.state_machine.states.map &:name
  end

  def pretty_status
    state.humanize
  end


  def pretty_submission_date
    submitted_at.strftime("%-d %B %Y")
  end

  def pretty_author
    "#{authors.first} et al."
  end
  
  def submitting_author
    User.first(:id => submitting_author_id)  
  end

  def assign_to(reviewer)
    reviewer_id = reviewer.id
    assigned
    save
  end

  def reviewer 
    User.first(:id => reviewer_id)
  end

  def suggest_reviewers
    User.where(:research_areas => category)
  end

  def arxiv_no
    arxiv_id.split("/").last
  end

  def is_reviwer(user)
    user.id == reviewer_id
  end

  def self.id_from_request_uri(uri)
    uri.split("/").last.split("?").first
  end

  def resolve_all_issues
    issues.each { |i| close_issue(i.number) }
  end

  # Might not want to do this
  def mark_all_issues_pending(new_version_id)
    issues.each do |i|
      add_comment_to_issue(i.number, "New ArXiv version detected (#{new_version_id})")
      update_issue(i.number, i.title, i.body, "Pending: #{new_version_id}")
    end
  end
  
  def add_issue(title, text)
    GITHUB_CONNECTION.create_issue(repo_name, title, text, :labels => review_name)
  end

  def update_issue(issue_id, title, text, labels=nil)
    GITHUB_CONNECTION.update_issue(repo_name, issue_id, title, text, :labels => labels)
  end

  def add_comment_to_issue(issue_id, text)
    GITHUB_CONNECTION.add_comment(repo_name, issue_id, text)
  end
  
  def close_issue(issue_id)
    GITHUB_CONNECTION.close_issue(repo_name, issue_id)
  end

  def repo_name
    github_address.match(/:([^\/]+\/.+?)\.git/)[1]
  end

  def all_comments
    GITHUB_CONNECTION.issues_comments(repo_name)
  end

  def open_issues 
    GITHUB_CONNECTION.list_issues(repo_name, :state=>"open")
  end

  def closed_issues
    GITHUB_CONNECTION.list_issues(repo_name, :state=>"closed")
  end

  def issues
    open_issues + closed_issues
  end

  def cover_image
    "https://raw.github.com/#{repo_name}/master/oja_pngs_#{arxiv_id}/#{arxiv_id}-small.png"
  end

  def issues_and_comments
    returned_issues = self.issues

    returned_issues.each do |issue|
      issue_url = issue.url
      issue['comments'] = []

      all_comments.each do |comment|
        # if the comment belongs to this issue
        if comment.issue_url == issue_url
          issue['comments'] << comment
        end
      end

      issue['comments'].sort_by { |comment| comment['id']}
    end

    return returned_issues
  end

  def review_name
    "Review ##{current_review_number}"
  end

  private

  def pull_arxiv_details
    github_address = ArxivDownloader.perform_async(self.arxiv_id, self.id)
    save
  end
end

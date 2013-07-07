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

  scope :under_review, :state => 'under_review'

  # has_many   :authors, :in => :author_ids
  # has_one    :submitting_author
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
  end
  
  def arxiv_no
    arxiv_id.split("/").last
  end

  def self.id_from_request_uri(uri)
    uri.split("/").last.split("?").first
  end

  def resolve_all_issues
    issues.each { |i| close_issue(i.number) }
  end

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

  def issues
    GITHUB_CONNECTION.list_issues(repo_name)
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

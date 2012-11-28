class Paper 
  include MongoMapper::Document
  key :title, String
  key :github_address, String
  key :version, String, :default => "1.0"
  key :state, String
  key :category, String
  key :arxiv_id, String
  key :author_ids, Array
  key :pdf_url, String
  key :pngs_generated, Boolean
  key :authors, Array
  key :submitted_at, DateTime

  # has_many   :authors, :in => :author_ids
  # has_one    :submitting_author
  # belongs_to :reviewer

  has_many :tasks

  after_create :pull_arxiv_details
  after_create :make_pngs
  
  state_machine :initial => :submitted do 
    state :submitted 
    state :accepted
  end
  
  def arxiv_no
    self.arxiv_id.split("/").last
  end


  private


  def pull_arxiv_details
    download = ArxivDownloader.perform_async(self.arxiv_id, self.id)
    self.github_address = download
    save
  end
  
  def make_pngs
    # PngGenerator.perform_async(self.id, self.pdf_url)
  end
end

class Paper < ActiveRecord::Base
  # attr_accessible :title, :body
  after_create :pull_arxiv_details
  
  state_machine :initial => :submitted do 
    state :submitted 
    state :accepted
  end
  
  private
  
  def pull_arxiv_details
    # Do something here
    # paper = ArxivDownloader.new(self.arxiv_id)
    # paper.download
  end
end

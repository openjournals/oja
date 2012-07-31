class ArxivDownloader
  attr_accessor :arxiv_id
  
  def initialize(arxiv_id, options = {})
    @arxiv_id = arxiv_id
  end
  
  def bundle_url
    "http://arxiv.org/e-print/#{arxiv_id}v1"
  end
  
  def download
    `curl #{bundle_url} -o tmp/#{arxiv_id}.tar.gz`
    `mkdir tmp/#{arxiv_id}`
    `tar -xf tmp/#{arxiv_id}.tar.gz -C tmp/#{arxiv_id}`
    `rm tmp/#{arxiv_id}.tar.gz`
  end
  
  def initialize_git
    # create git repo here
  end
  
  def add_files_to_git
    
  end
end
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
  
  def initialize_git(arxiv_id)
    repo = GITHUB_CONNECTION.create_repository(arxiv_id)
    `cd tmp/#{arxiv_id}`
    `git init`
    `git add *`
    `git commit -m 'Adding initial paper'`
    `git remote add origin #{repo.clone_url}`
    `git push -u origin master`
  end
  
  def add_files_to_git
    
  end
end
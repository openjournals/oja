class ArxivDownloader
  include Sidekiq::Worker
  
  def perform(arxiv_id, paper_id)
    puts "Downloading"
    download(arxiv_id)
    initialize_git(arxiv_id, paper_id)
  end
  
  def download(arxiv_id)
    `curl "http://arxiv.org/e-print/#{arxiv_id}v1" -o tmp/#{arxiv_id}.tar.gz`
    `mkdir tmp/#{arxiv_id}`
    `tar -xf tmp/#{arxiv_id}.tar.gz -C tmp/#{arxiv_id}`
    `rm tmp/#{arxiv_id}.tar.gz`
  end
  
  def initialize_git(arxiv_id, paper_id)
    puts "Creating GitHub repository"
    repo = GITHUB_CONNECTION.create_repository(arxiv_id)
    puts "GitHub address: #{repo.ssh_url}"
            
    `cd tmp/#{arxiv_id} && git init`
    `cd tmp/#{arxiv_id} && git add *`
    
    puts "Creating initial commit"
    
    `cd tmp/#{arxiv_id} && git commit -m 'Adding initial paper'`
    
    `cd tmp/#{arxiv_id} && git remote add origin #{repo.ssh_url}`    
    `ssh-agent bash -c 'ssh-add -D; ssh-add /Users/arfon/Sites/Adler/oja/config/ssh/***REMOVED***_rsa; cd tmp/#{arxiv_id} && git push -u origin master'`

    paper = Paper.find(paper_id)
    paper.github_address = repo.ssh_url
    paper.save
  end
end
class ArxivDownloader
  include Sidekiq::Worker
  
  def perform(arxiv_id, paper_id)
    puts "Downloading"
    download(arxiv_id)
    initialize_git(arxiv_id, paper_id)
  end
  
  def download(arxiv_id)
    logger.fatal { "Starting download of #{arxiv_id}" }
    `curl "http://arxiv.org/e-print/#{arxiv_id}v1" -o #{Rails.root}/tmp/#{arxiv_id}.tar.gz`
    `mkdir #{Rails.root}/tmp/#{arxiv_id}`
    `tar -xf #{Rails.root}/tmp/#{arxiv_id}.tar.gz -C #{Rails.root}/tmp/#{arxiv_id}`
    `rm #{Rails.root}/tmp/#{arxiv_id}.tar.gz`
    logger.fatal { "Completing download of #{arxiv_id}" }
  end
  
  def initialize_git(arxiv_id, paper_id)
    logger.fatal { "Creating GitHub repository" }
    repo = GITHUB_CONNECTION.create_repository(arxiv_id)
    logger.fatal { "GitHub address: #{repo.ssh_url}" }
    
    `cd #{Rails.root}/tmp/#{arxiv_id} && mkdir oja_pngs_#{arxiv_id}`
    `cd #{Rails.root}/tmp/#{arxiv_id} && curl -O http://arxiv.org/pdf/#{arxiv_id}.pdf`
    `cd #{Rails.root}/tmp/#{arxiv_id}/oja_pngs_#{arxiv_id} && convert -density 300 ../#{arxiv_id}.pdf -bordercolor white -border 0 -resize 140 +adjoin #{arxiv_id}-small.png`      
    `cd #{Rails.root}/tmp/#{arxiv_id} && git init`
    `cd #{Rails.root}/tmp/#{arxiv_id} && git add *`
    
    logger.fatal { "Creating initial commit" }
    
    `cd #{Rails.root}/tmp/#{arxiv_id} && git commit -m 'Adding initial paper'`
    
    `cd #{Rails.root}/tmp/#{arxiv_id} && git remote add origin #{repo.ssh_url}`    
    `ssh-agent bash -c 'ssh-add -D; ssh-add config/ssh/***REMOVED***_rsa; cd #{Rails.root}/tmp/#{arxiv_id} && git push -u origin master'`

    paper = Paper.find(paper_id)
    paper.github_address = repo.ssh_url
    paper.save
  end
end
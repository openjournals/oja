class ArxivDownloader
  include Sidekiq::Worker
  
  def perform(arxiv_id, paper_id)
    puts "Downloading"
    download(arxiv_id)
    initialize_git(arxiv_id, paper_id)
  end
  
  def download(arxiv_id)
    `curl "http://arxiv.org/e-print/#{arxiv_id}v1" -o #{RAILS_ROOT}/tmp/#{arxiv_id}.tar.gz`
    `mkdir #{RAILS_ROOT}/tmp/#{arxiv_id}`
    `tar -xf #{RAILS_ROOT}/tmp/#{arxiv_id}.tar.gz -C #{RAILS_ROOT}/tmp/#{arxiv_id}`
    `rm #{RAILS_ROOT}/tmp/#{arxiv_id}.tar.gz`
  end
  
  def initialize_git(arxiv_id, paper_id)
    puts "Creating GitHub repository"
    repo = GITHUB_CONNECTION.create_repository(arxiv_id)
    puts "GitHub address: #{repo.ssh_url}"
    
    `cd #{RAILS_ROOT}/tmp/#{arxiv_id} && mkdir oja_pngs_#{arxiv_id}`
    `cd #{RAILS_ROOT}/tmp/#{arxiv_id} && curl -O http://arxiv.org/pdf/#{arxiv_id}.pdf`
    `cd #{RAILS_ROOT}/tmp/#{arxiv_id}/oja_pngs_#{arxiv_id} && convert -density 300 ../#{arxiv_id}.pdf -bordercolor white -border 0 -resize 140 +adjoin #{arxiv_id}-small.png`      
    `cd #{RAILS_ROOT}/tmp/#{arxiv_id} && git init`
    `cd #{RAILS_ROOT}/tmp/#{arxiv_id} && git add *`
    
    puts "Creating initial commit"
    
    `cd #{RAILS_ROOT}/tmp/#{arxiv_id} && git commit -m 'Adding initial paper'`
    
    `cd #{RAILS_ROOT}/tmp/#{arxiv_id} && git remote add origin #{repo.ssh_url}`    
    `ssh-agent bash -c 'ssh-add -D; ssh-add config/ssh/***REMOVED***_rsa; cd #{RAILS_ROOT}/tmp/#{arxiv_id} && git push -u origin master'`

    paper = Paper.find(paper_id)
    paper.github_address = repo.ssh_url
    paper.save
  end
end
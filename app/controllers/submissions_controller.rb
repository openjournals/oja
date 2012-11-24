class SubmissionsController < ApplicationController
  def index
    
  end
  
  def new
    
  end

  def create
    if valid_url(params[:arxiv_id])
      manuscript = Arxiv.get(params[:arxiv_id])
      paper = Paper.new(:title => manuscript.title,
                        :version => manuscript.version,
                        :arxiv_id => params[:arxiv_id],
                        :pdf_url => manuscript.pdf_url,
                        :authors => manuscript.authors.collect { |a| a.name },
                        :submitted_at => manuscript.created_at)
      
      paper.save
    end
    
    redirect_to :action => "show", :id => paper.id
  end
  
  def show
    @paper = Paper.find(params[:id])
  end
  
  def status
    @paper = Paper.find(params[:id])
  end
  
  def valid_url(arxiv_id)
    # http://arxiv.org/abs/1211.3105
    require "net/http"
    url = URI.parse("http://arxiv.org/abs/#{arxiv_id}")
    req = Net::HTTP.new(url.host, url.port)
    res = req.request_head(url.path)
    if res.code == "200"
      return true
    else
      return false
    end
  end
end

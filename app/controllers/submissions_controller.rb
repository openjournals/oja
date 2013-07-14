class SubmissionsController < ApplicationController
  before_filter :authenticate_user!, :only => [:dashboard, :new]
  
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
                        :submitted_at => manuscript.created_at,
                        :category => manuscript.primary_category.abbreviation)

      paper.submitting_author_id = current_user.id
      
      paper.save
    end
    
    redirect_to :action => "show", :id => paper.id
  end

  def review
    @paper = Paper.find(params[:id]) || Paper.where(arxiv_id: Paper.id_from_request_uri(request.env["REQUEST_URI"])).first 
    raise ActionController::RoutingError.new('Not Found')  unless @paper 
  end

  def respond 
    @paper = Paper.find(params[:id]) || Paper.where(arxiv_id: Paper.id_from_request_uri(request.env["REQUEST_URI"])).first 
    raise ActionController::RoutingError.new('Not Found')  unless @paper 
  end
  
  def show
    @paper = Paper.find(params[:id]) || Paper.where(arxiv_id: Paper.id_from_request_uri(request.env["REQUEST_URI"])).first 
    raise ActionController::RoutingError.new('Not Found')  unless @paper 
  end
  
  def status
    @paper =  Paper.find(params[:id]) || Paper.where(arxiv_id: Paper.id_from_request_uri(request.env["REQUEST_URI"])).first 
    raise ActionController::RoutingError.new('Not Found')  unless @paper 
  end
  
  def dashboard
    if current_user.is_editor?
      redirect_to :action => :editor_dashboard
    elsif current_user.is_reviewer?
      redirect_to :action => :reviewer_dashboard
    else 
      redirect_to :action => :author_dashboard
    end
  end

  def reviewer_dashboard
    redirect_to :action=>:dashboard unless  current_user.roles.include? "reviewer"
    @papers_in_review = current_user.papers_for_review
    @accepted_papers   = current_user.accepted_papers
  end

  def editor_dashboard
    redirect_to :action=>:dashboard unless  current_user.roles.include? "editor"
    @submitted_papers = Paper.submitted.all
    @papers_in_review = Paper.in_review.all
    @accepted_papers  = Paper.accepted.all
    @reviewers = User.reviewers
  end

  def author_dashboard
    @papers = current_user.papers
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

class PapersController < ApplicationController
  respond_to :json
  before :get_paper, :except=>[:index]

  def index
    @papers = Paper.all

    respond_with @papers
  end

  def show
    @paper = Paper.find(params[:id])
    respond_with @paper
  end

  def assign_for_review
    reviewer = User.find(params[:reviwer_id])

    unless reviewer and review.is_reviewer?
      raise ActionController::RoutingError.new('Not Found')

    if current_user and current_user.is_editor? 
        @paper.assign_to reviewer
        respond_with @paper
    else 
      raise ActionController::RoutingError.new('Forbidden')
    end
  end

  def update_status
    state = params[:state]
    if current_user.editor? or @paper.is_reviewer(current_user)
      @paper.update_state state
      respond_with @paper
    else 
      raise ActionController::RoutingError.new('Forbidden')
    end
  end 

  def get_paper
    @paper = Paper.find(params[:id])
    unless @paper 
      raise ActionController::RoutingError.new('Not Found')
    end
    @paper
  end

end

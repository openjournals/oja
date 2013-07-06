class IssuesController < ApplicationController
  respond_to :json

  before_filter :find_paper

  def index
    issues = @paper.issues

    respond_with issues
  end

  # expecting title, text
  def create
    title = params[:issue][:title]
    text = params[:issue][:text]
    
    begin
      issue = @paper.add_issue(title, text)
      respond_with issue, :status => :created
    rescue => e
      puts "Oh noes!"
      respond_with {}, :status => :internal_server_error
    end
  end

  private

  def find_paper
    @paper = Paper.find(params[:paper_id])
  end
end

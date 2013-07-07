class IssuesController < ApplicationController
  respond_to :json

  before_filter :find_paper

  def index
    issues = @paper.issues

    # get the issues and the comments
    respond_with issues
  end

  # expecting {"issue": {"title":"Issue title", "text":"Issue text body"}}
  def create
    title = params[:issue][:title]
    text = params[:issue][:text]
    
    page = params[:issue][:page]
    offset = params[:issue][:offset]

    title = "Page: #{page} Offset: #{offset} Title: #{title}"
    
    begin
      issue = @paper.add_issue(title, text)
      render :json => {:issue_number => issue.number}, :status => :created
    rescue => e
      respond_with @paper, :status => :internal_server_error
    end
  end

  # def add_comment_to_issue(issue_id, text, labels=nil)
  #   GITHUB_CONNECTION.add_comment(repo_name, issue_id, text, :labels => labels)
  # end
  # expecting {"issue": {"number":"issue_number", "text":"Issue text body"}}
  # /papers/id/issues/id/add_comment
  def add_comment
    issue_number = params[:id]
    text = params[:issue][:text]

    begin
      issue = @paper.add_comment_to_issue(issue_number, text)
      render :json => {:issue_number => issue.number}, :status => :created
    rescue => e
      respond_with @paper, :status => :internal_server_error
    end
  end

  # expecting PUT {"issue": {"number":"issue_number"}}
  # /papers/id/issues/id/close
  def close
    issue_number = params[:id]

    begin
      issue = @paper.close_issue(issue_number)
      render :json => {:issue_number => issue_number}, :status => :created
    rescue => e
      respond_with @paper, :status => :internal_server_error
    end
  end

  private

  def find_paper
    @paper = Paper.find(params[:paper_id])
  end
end

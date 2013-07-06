class IssuesController < ApplicationController
  respond_to :json

  before_filter :find_paper

  def index
    issues = @paper.issues

    respond_with issues
  end

  private

  def find_paper
    @paper = Paper.find(params[:paper_id])
  end
end

class PapersController < ApplicationController
  respond_to :json

  def index
    @papers = Paper.all

    respond_with @papers
  end

  def show
    @paper = Paper.find(params[:id])

    respond_with @paper
  end
end

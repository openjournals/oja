class HomeController < ApplicationController
  def index 
    @user = current_user
    @papers = Paper.accepted.all
  end
end

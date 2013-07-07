class RegistrationsController < Devise::RegistrationsController
  def new
    super
  end

  def create
    build_resource
    
    if resource.save
      set_flash_message :notice, :signed_up
      sign_in(resource_name, resource)
      redirect_to :controller => "submissions", :action => "dashboard"
    else
      clean_up_passwords resource
      session[:errors]= resource.errors.messages
    end
  end 
end

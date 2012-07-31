class Paper < ActiveRecord::Base
  # attr_accessible :title, :body
  
  state_machine :initial => :submitted do 
    state :submitted 
    state :accepted
  end
end

class Task
  include MongoMapper::Document
  key :type, String, :in => ['review', 'assign']
  key :stage, Integer 

  belongs_to :editor
  belongs_to :reviewer
  timestamps!
  
end

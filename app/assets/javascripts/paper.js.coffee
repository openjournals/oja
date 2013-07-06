class Paper 

  constructor:(paper_id)->
    @paper_id = paper_id 

  fetch_issues:=>
    @issues = []
    $.getJSON("/submissions/#{paper_id}/issues") (data)=>
      for issue in data 
        @issues.push new Issue(issue)
   
  

class Issue

  constructor:(_iss)->
    @id         = _iss.id
    @body       = _iss.body 
    @created_at = _iss.created_at
    

  update:(text)->
    $.post("/submissions/#{paper_id}/issues/#{@id}/udpate", text)
    
  render:=>
    """ 
      <div class='comment' data-id='#{@id}'>
        <div class='header'>
          <span class='created_at'> #{@created_at} </span>
          <span class='edit'> edit </span>
        </div>
        <div class='body'>
          #{@body}
        </div>
      </div>
    """


window.Paper = Paper
window.Issue = Issue



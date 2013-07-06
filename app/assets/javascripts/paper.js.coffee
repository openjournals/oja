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
    @offset     = _iss.offset
    @page       = _iss.page

  update:(text)->
    $.post("/submissions/#{paper_id}/issues/#{@id}/udpate", text)
    
  renderEditor:(el)=>
    $(el).append """
      <div class='comment_editor' style='top:#{@offset}px' data-id="#{@id}">
        <div class='header'>
          <span>New issue</span>
          <span class='close'>x</span>
        </div>
        <div class='body'>
          <textarea placeholder='Write your issue here...'></textarea>
          <a href='#' class='button'>Add </a>
        </div>
      </div>'
    """


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



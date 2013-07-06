class Paper 

  constructor:(paper_id)->
    @paper_id = paper_id 

  fetch_issues:=>
    @issues = []
    $.getJSON("/submissions/#{paper_id}/issues") (data)=>
      for issue in data 
        @issues.push new Issue(issue)
   
  

class Issue

  constructor:(_iss, el)->
    @id         = (_iss.id || Math.floor(Math.random()*200000))
    @body       = _iss.body 
    @comments   = _iss.comments || []
    @created_at = _iss.created_at
    @offset     = _iss.offset
    @page       = _iss.page
    @el         = el
    @created_at = new Date()

    @commentsEnabled = false

  update:(text)->
    $.post("/submissions/#{paper_id}/issues/#{@id}/udpate", text)
    
  renderEditor:=>
    $(@el).append """
      <div class='comment_editor comment-#{@id} page-#{@page}' style='top:#{@offset}px' data-id="#{@id}">
        <div class='header'>
          <span>New issue</span>
          <span class='close'>x</span>
        </div>
        <div class='body'>
          <textarea placeholder='Write your issue here...'></textarea>
          <a href='#' class='button add'>Add </a>
        </div>
      </div>
    """
    @setUpEvents()

  enableComments:=>
    @commentsEnabled = true 

  setUpEvents:=>
    $(" .close").click (e)=>
      e.preventDefault()
      $(e.currentTarget).parent().parent().remove()

    $(".add").click (e)=>
      e.preventDefault()
      @body = $(e.currentTarget).siblings("textarea").val()
      $(e.currentTarget).parent().parent().remove()
      @render()


  renderCommentAdder:=>
    $(@el).append """
      <div id='comment-#{@id}' class='comment comment-#{@id} page-#{@page}' style='top:#{@offset}px' data-id='#{@id}'>
        <div class='header'>
          <span class='created_at'> #{@created_at} </span>
          <span class='edit'> edit </span>
        </div>
        <div class='body'>
          #{@body}
        </div>
        <div class='comment'>
          <textarea placeholder='Add your comment here'></textarea>
          <a class='button add'>Add</a>
        </div>
      </div>
    """


  render:=>
    
    $(@el).append """
      <div id='comment-#{@id}' class='comment comment-#{@id} page-#{@page}' style='top:#{@offset}px' data-id='#{@id}'>
        <div class='header'>
          <span class='created_at'> #{@created_at} </span>
          <span class='edit'> edit </span>
        </div>
        <div class='body'>
          #{@body}
        </div>
      </div>
    """

    setTimeout =>
      MathJax.Hub.Queue(["Typeset",MathJax.Hub,  document.getElementById("comment-#{@id}")]);
    ,200


window.Paper = Paper
window.Issue = Issue



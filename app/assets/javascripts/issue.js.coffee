class Issue

  constructor:(_iss, el=null)->
    for key, val of _iss 
      @[key] = val

    @id  ||= Math.floor(Math.random()*200000)

    @parseTitle()
    @el         = el
    @created_at ||= new Date()
    @commentsEnabled = true


    @comments ||= []

  update:(text)->
    $.post("/papers/#{@paper_id}/issues", {issue: {title:"issue-#{@id}", text: @body, offset: @offset, page: @page}})


  formatedDate:=>
    @created_at 

  renderEditor:=>
    $(@el).append """
      <div class='issue_editor issue-#{@id} page-#{@page}' style='top:#{@offset}px' data-id="#{@id}">
        <div class='header'>
          <span>New issue</span>
          <span class='close'>x</span>
        </div>
        <div class='body'>
          <textarea placeholder='Write your issue here...'></textarea>
          <a href='#' class='button add'>Add</a>
        </div>
      </div>
    """
    @setUpEvents()

  parseTitle:=>
    if @title
      @offset = parseInt(@title.match(/Offset:\W+[0-9]+/)[0].split(":")[1])
      @page   = parseInt(@title.match(/Page:\W+[0-9]+/)[0].split(":")[1])


  enableComments:=>
    @commentsEnabled = true 

  setUpEvents:=>
    $(".issue_editor .close").click (e)=>
      e.preventDefault()
      $(e.currentTarget).parent().parent().remove()

    $(".issue_editor .add").click (e)=>
      e.preventDefault()
      @body = $(e.currentTarget).siblings("textarea").val()
      $(e.currentTarget).parent().parent().remove()
      @render()
      @update()

    $("#issue-#{@id} .comment").click (e)=>
      e.preventDefault()
      $("#issue-#{@id} .commentAdder").show()

    $("#issue-#{@id} .addComment").click (e)=>
      e.preventDefault()
      comment = $(e.currentTarget).siblings("textarea").val()
      @saveComment(comment)
  
      $("#issue-#{@id}").remove()
      @render()
      # @update()

    $("#issue-#{@id} .close_issue").click (e)=>
      @closeIssue()
      @state = "closed"
      $("#issue-#{@id}").remove()
      @render()


  closeIssue:=>
    $.ajax
      url: "/papers/#{@paper_id}/issues/#{@number}/close"
      data: {}
      type: "PUT"

  saveComment:(comment)=>
    @comments.push {body: comment}

    $.ajax
      url: "/papers/#{@paper_id}/issues/#{@number}/add_comment"
      data: {issue:{text: comment}}
      type: "PUT"



  renderIssueAdder:=>
    $(@el).append """
      <div id='issue-#{@id}' class='issue issue-#{@id} page-#{@page}' style='top:#{@offset}px' data-id='#{@id}'>
        <div class='header'>
          <span class='created_at'> #{@created_at} </span>
          <span class='actions'> #{@created_at} </span>
        </div>
        <div class='body'>
          #{@body}
        </div>
        <div class='comment'>
          <textarea placeholder='Add your issue here'></textarea>
          <a class='button add'>Add</a>
        </div>
      </div>
    """

  renderCommentAdder:=>
    """
      <div style='display:none' class='commentAdder'>
        <textarea placeholder='add your comment here'></textarea>
        <a class='button addComment'>Add Comment</a>
      </div>
    """

  renderComments:=>
    console.log @comments
    comments = ("<li><span class='comment_header'>#{moment(comment.created_at).format('Do MMMM YYYY HH:mm:ss')}</span><span class='comment_body'>#{comment.body}</span></li>" for comment in @comments.reverse() ).join("\n")
    """
      <ul class='commentList'>
        #{comments}
      </ul>
    """

  render:=>

    if @state=='open' 
      button = "<a class='button comment'>Comment</a>"
    else 
      button = ""

    $(@el).append """
      <div id='issue-#{@id}' class='issue issue-#{@id} page-#{@page} #{@state}' style='top:#{@offset}px' data-id='#{@id}'>
        <div class='header'>
          <span class='created_at'> #{moment(@created_at).format('Do MMMM YYYY HH:mm:ss')}</span>
          <span class='close_issue'>#{ if @state=='open' then "Close Issue" else ""  }</span>
        </div>
        <div class='body'>
          #{@body}
          #{button}
        </div>
        #{@renderComments()}
        #{@renderCommentAdder()}
      </div>
    """

    @setUpEvents()


    setTimeout =>
      MathJax.Hub.Queue(["Typeset",MathJax.Hub,  document.getElementById("comment-#{@id}")]);
    ,200


window.Issue = Issue
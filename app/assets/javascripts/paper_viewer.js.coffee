class PaperViewer

  constructor:(paper_id, el, controls_el, scale, issues_entabled=false, @issues_el=null, role ="author")->

    @el = el
    @controls_el = controls_el
    @paper_id = paper_id
    @role  = role 
    @issues_enabled = issues_entabled
    @render()

    PDFJS.disableWorker = true;
    @pdfDoc = null
    @pageNum = 1
    @scale = scale
    @canvas = document.getElementById("paper-#{@paper_id}")
    @ctx = @canvas.getContext('2d')

    PDFJS.getDocument("/proxy/#{@paper_id}").then (pdfDoc)=>
      @pdfDoc = pdfDoc
      @renderPage(@pageNum)
      @renderControlls() if @controls_el
      $(".pages .total_pages").html  @pdfDoc.numPages

  toggle_issues:=>
    @issues_entabled = not @issues_entabled

  render:=>
    $(@el).append """
      <canvas id = 'paper-#{@paper_id}'></canvas>
    """

  renderControlls:=>
    

    content = """
      <p class='pages'>
        Page: <span class='page_no'>#{@page_no}</span> of <span class='total_pages'>#{@pdfDoc.numPages}</span>
      </p>
      <p class='next_prev'>
        <span class='prev'> ◀ </span>
        <span class='next'> ▶ </span>
      </p>
    """

    if @role == "editor"
      content  = content + """
        <p class='actions'>
          <a  href='#' class='button reject'>Reject</a>
          <a  href='#' class='button accept'>Accept</a>
          <a  href='#' class='button revise'>Revison</a>
        </p>
      """

    $(@controls_el).append content

    @setup_events()

  setup_events:=>
    $(".prev").click => 
      @goPrevious()
  
    $(".next").click => 
      @goNext()

    $(@el).click (event)=>
      event.preventDefault()
      offset = event.offsetY 
      issue = new Issue({page: @pageNum, offset:offset}, @issues_el)
      issue.renderEditor()




  renderPage:(num)=> 
    #Using promise to fetch the page
    @pdfDoc.getPage(num).then (page)=>
      @viewport = page.getViewport(@scale);
      @canvas.height = @viewport.height;
      @canvas.width = @viewport.width;

    #Render PDF page into canvas context
      @renderContext =
        canvasContext: @ctx
        viewport: @viewport
        
      page.render(@renderContext)
      
      @page_no = num 

      #Update page counters
      $(".pages .page_no").html  @pageNum
      document.getElementById('page_count').textContent = @pdfDoc.numPages

  switchComments:=>
    $(".comment").hide()
    $(".comment-editor").hide()
    $(".page-#{@pageNum}").show()

  goPrevious:=>
    unless (@pageNum <= 1)
      @pageNum -= 1 
      @renderPage(@pageNum)
      @switchComments()

  goNext:=> 
    unless (@pageNum >= @pdfDoc.numPages)
      @pageNum += 1
      @renderPage(@pageNum)
      @switchComments()      


window.PaperViewer = PaperViewer

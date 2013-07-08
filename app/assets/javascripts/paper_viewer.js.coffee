class PaperViewer

  constructor:(paper, el, controls_el, scale, issues_entabled=false, @issues_el=null, @issue_list_el=null, role ="author")->

    @el = el
    @controls_el = controls_el
    @paper  = paper 
    
    @paper_id = paper.arxiv_id
    @bson_id = paper.id

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
      @paper.fetch_issues @renderIssues


  toggle_issues:=>
    @issues_entabled = not @issues_entabled

  render:=>
    $(@el).append """
      <canvas id = 'paper-#{@paper_id}'></canvas>
    """

  renderIssues:=>
    for issue in @paper.issues
      issue.el = @issues_el
      issue.render()
      # @issue_list_el.append issue.render()

    @switchIssues()

  

  renderControlls:=>
    

    content = """
      <p class='pages'>
        Page: <span class='page_no'>#{@page_no}</span> of <span class='total_pages'>#{@pdfDoc.numPages}</span>
      </p>
      <p class='next_prev'>
        <span class='prev'> ◀ </span>
        <span class='next'> ▶ </span>
        <span class='toggle_paper_view active'>☱</span>
      </p>


      <p  class='right review_stage'> Review round : #{@paper.current_review_number} </p>
      <p  class='right issue_count'> Outstanding issues : <span class='issue_count_no'>0</span> </p>
      <p  class='right issue_count'> Resolved issues : <span class='issue_closed_count_no'>0</span> </p>


    """
    @role = "editor"
    if @role == "editor"
      content  = content + """
        <p class='right actions'>
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
      issue = new Issue({paper_id:@bson_id, page: @pageNum, offset:offset, state: "open"}, @issues_el)
      issue.renderEditor()

    $(".toggle_paper_view").click =>
      $(".toggle_paper_view").toggleClass("active")
      $(".review_interface").toggleClass("hide_paper")
      if $(".toggle_paper_view").hasClass('active')
        @switchIssues()
      else 
        $(".issue").show()


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

  switchIssues:=>
    $(".issue").hide()
    $(".issue-editor").hide()
    $(".page-#{@pageNum}").show()

  goPrevious:=>
    unless (@pageNum <= 1) or !$(".toggle_paper_view").hasClass('active')
      @pageNum -= 1 
      @renderPage(@pageNum)
      @switchIssues()

  goNext:=> 
    unless (@pageNum >= @pdfDoc.numPages) or !$(".toggle_paper_view").hasClass('active')
      @pageNum += 1
      @renderPage(@pageNum)
      @switchIssues()      


window.PaperViewer = PaperViewer

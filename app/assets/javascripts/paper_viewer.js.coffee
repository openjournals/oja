class PaperViewer

  constructor:(paper_id, el, controls_el, scale)->

    @el = el
    @controls_el = controls_el
    @paper_id = paper_id
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
     
  render:=>
    $(@el).append """
      <div class='page_num'></div>
      <div class='page_count'></div>
      <canvas id = 'paper-#{@paper_id}'></canvas>
      <div class='prev'></div>
      <div class='next'></div>
    """

  renderControlls:=>
    $(@controls_el).append """
      <p class='pages'>
        Page: <span class='page_no'>#{@page_no}</span> of <span class='total_pages'>#{@pdfDoc.numPages}</span>
      </p>
      <p class='next_prev'>
        <span class='prev'> ◀ </span>
        <span class='next'> ▶ </span>
      </p>
    """

    @setup_events()

  setup_events:=>
    $(".prev").click => 
      @goPrevious()
  
    $(".next").click => 
      @goNext()

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


  goPrevious:=>
    unless (@pageNum <= 1)
      @pageNum -= 1 
      @renderPage(@pageNum)

  goNext:=> 
    unless (@pageNum >= @pdfDoc.numPages)
      @pageNum += 1
      @renderPage(@pageNum)
      


window.PaperViewer = PaperViewer

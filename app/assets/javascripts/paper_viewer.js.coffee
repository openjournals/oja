class PaperViewer

  constructor:(el , element,scale)->
    PDFJS.disableWorker = true;
    @pdfDoc = null
    @pageNum = 1
    @scale = scale
    @canvas = document.getElementById(el)
    @ctx = canvas.getContext('2d')

   


    PDFJS.getDocument("/proxy/<%=@id%>").then (_pdfDoc)->
        @pdfDoc = _pdfDoc
        @renderPage(pageNum)
     
    render:=>
      $(el).append """
        <div class='page_num'></div>
        <div class='page_count'></div>
        <div id = 'paper'></div>
        <div class='prev'></div>
        <div class='next'></div>
      """
      @setup_events()

    setup_events:->
      $(".prev").click -> 
        @goPrevious()
    
      $(".next").click -> 
        @goNext()
        
    renderPage:(num)=> 
      #Using promise to fetch the page
      @pdfDoc.getPage(num).then (page)->
        @viewport = page.getViewport(scale);
        @canvas.height = viewport.height;
        @canvas.width = viewport.width;

      #Render PDF page into canvas context
        @renderContext =
          canvasContext: @ctx
          viewport: @viewport
          
        @page.render(renderContext)
      

        #Update page counters
        document.getElementById('page_num').textContent = pageNum
        document.getElementById('page_count').textContent = pdfDoc.numPages


    goPrevious:=>
      unless (pageNum <= 1)
        @pageNum -= 1 
        @renderPage(@pageNum)

    goNext:=> 
      unless (pageNum >= @pdfDoc.numPages)
        @pageNum += 1
        @renderPage(@pageNum)
      


window.PaperViewer = PaperViewer

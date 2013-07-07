class Paper 

  constructor:(paper)->
    for key,val of paper 
      @[key] = val  


  fetch_issues: (cb)=>
    @issues = []
    console.log "fetching issues"

    $.getJSON "/papers/#{@id}/issues", (data)=>
      
      for issue in data 
        issue.paper_id = @id
        @issues.push(new Issue(issue))
      $(".issue_count_no").html @issues.length
      cb() if cb

  add_issue:(issue)=>
    @issues.push issue 

window.Paper = Paper



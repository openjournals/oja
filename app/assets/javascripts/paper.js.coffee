class Paper 

  constructor:(paper)->
    for key,val of paper 
      @[key] = val  


  fetch_issues: (cb)=>
    @issues = []
    console.log "fetching issues"

    $.getJSON "/papers/#{@id}/issues", (data)=>
      console.log "data comming back",data
      for issue in data 
        @issues.push(new Issue(issue))
      cb() if cb

  add_issue:(issue)=>
    @issues.push issue 

window.Paper = Paper



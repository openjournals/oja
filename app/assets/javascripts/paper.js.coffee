class Paper 

  constructor:(paper)->
    for key,val of paper 
      @[key] = val  


  fetch_issues: (cb)=>
    @issues = []

    $.getJSON "/papers/#{@id}/issues", (data)=>
      
      for issue in data 
        issue.paper_id = @id
        @issues.push(new Issue(issue))

      $(".issue_count_no").html (issue for issue in @issues when issue.state=='open').length
      $(".issue_closed_count_no").html (issue for issue in @issues when issue.state=='closed').length

      @issues = _.sortBy @issues, (issue)->
        (issue.page*1000 + issue.offset)

      cb() if cb

  add_issue:(issue)=>
    @issues.push issue 

window.Paper = Paper



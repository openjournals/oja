class Paper 

  constructor:(paper_id)->
    @paper_id = paper_id 

  fetch_issues:=>
    @issues = []
    $.getJSON("/submissions/#{paper_id}/issues") (data)=>
      for issue in data 
        @issues.push new Issue(issue)
      
class Issue

  update:(text)->
    $.post("/submissions/#{paper_id}/issues/#{@id}/udpate", text)
    

window.Paper = Paper
window.Comment = Comment



# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/


$ ->  

  $(".auto-replace").focus ->
    $(this).val('')
  
  $(".auto-replace").blur ->
    val = $(this).val()
    if val is ""
      $(this).val($(this).attr('data-original-text'))

  $(".tab.view").click -> 
    window.location.replace('/submissions/dashboard')

  $(".tab.edit").click -> 
    window.location.replace('/submissions')



  
  $(".cover_image").click (e)->
    el = $(e.currentTarget)
    $('.cover_image').removeClass('selected')
    el.addClass('selected')
    paper = (paper for paper in papers when paper.id == el.attr("id"))[0]


    if window.user.roles.indexOf("editor")>-1 and paper.state=='submitted'
      reviewer_options = ("<option value='#{reviewer.id}'>#{reviewer.first_name} #{reviewer.last_name} </option>" for reviewer in window.reviewers)

      action= """
        <p> Assign to reviewer </p>
        <form class='reviewer_assign'>
          <select name='reviwer_id' class='reviewer_select_list' placeholder="reviewers" >
          <option>Select a reviewer</option>
          #{reviewer_options}
          </select>
        </form>
        <a class='assign_reviewer small-blue-button'>submit</a>
      """
    else if window.current_user.roles.indexOf("editor")>-1 and paper.state=='submitted'
      action = """<a href="/submissions/#{paper.id}/review" class="review-button .add_reviwer">Begin Review</a>"""



    $(".paper").html """
      <p class="kind">Title</p>
      <p class="value">#{paper.title}</p>
      
      <p class="kind">Author</p>
      <p class="value">#{paper.pretty_author}</p>

      <p class="kind">Category</p>
      <p class="value">#{paper.category}</p>
      
      <p class="kind">Submission Date</p>
      <p class="value">#{paper.pretty_submission_date}</p>
      
      <p class="kind">Review Status</p>
      <p class="value">#{paper.pretty_status}</p>
      #{action}
    """


    $(".assign_reviewer").click (e)->
      e.preventDefault()
      reviwer_id = $(".reviewer_select_list").val()

      $.post("/paper/#{paper.id}/assign_for_review/#{reviwer_id}")    



  $(".tab").click (e) ->
    e.preventDefault()
    type = $(@).data().ptype
    $(".tab").removeClass("active")
    $(".tab."+type).addClass("active")
    $(".dashboard").removeClass("active")
    $(".dashboard."+type).addClass("active")
    

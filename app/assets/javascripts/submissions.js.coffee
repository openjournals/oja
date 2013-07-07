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
  
  $(".tab.submit").click -> 
    window.location.replace('/submissions/new')

  $(".tab.view").click -> 
    window.location.replace('/submissions/dashboard')

  $(".tab.edit").click -> 
    window.location.replace('/submissions')
        
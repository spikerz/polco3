$("#vote_buttons").find(".btn").each ->
  $(this).bind "click", ->
    console.log "value clicked: " + @value
    $("#vote_value").val(@value)
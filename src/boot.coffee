window.Safarikai = (->
  readDataFile = (file) ->
    req = new XMLHttpRequest()
    req.open "GET", safari.extension.baseURI + "data/" + file, false
    req.send null
    fileContent = req.responseText

  boot: ->
    console.log "Safarikai global script booted."
)()

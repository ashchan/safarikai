window.Safarikai = (->
  readDataFile = (file) ->
    req = new XMLHttpRequest()
    req.open "GET", safari.extension.baseURI + "data/" + file, false
    req.send null
    fileContent = req.responseText

  messageEventHandler = (e) ->
    messageName = e.name
    messageData = e.message
    console.log messageData
    # TODO: filter and dispatch messages

  boot: ->
    safari.application.addEventListener "message", messageEventHandler, false
    console.log "Safarikai global script booted."
)()

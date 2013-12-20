(->
  readDataFile = (file) ->
    req = new XMLHttpRequest()
    req.open "GET", safari.extension.baseURI + "data/" + file, false
    req.send null
    fileContent = req.responseText

  queryWord = ""
  result = ""
  lookupWord = (word) ->
    if queryWord != word
      queryWord = word
      result = queryWord
    safari.application.activeBrowserWindow.activeTab.page.dispatchMessage "showResult", { word: queryWord, result: result }

  messageEventHandler = (e) ->
    messageName = e.name
    messageData = e.message

    switch messageName
      when "lookupWord" then lookupWord messageData

  safari.application.addEventListener "message", messageEventHandler, false
  console.log "Safarikai global script booted."
)()

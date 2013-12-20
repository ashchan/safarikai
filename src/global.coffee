Safarikai =
  initialize: ->
    @enabled   = false
    @queryWord = ""
    @result    = ""

  sendStatus: (page) ->
    page.dispatchMessage "status", { enabled: @enabled }

  toggle: ->
    @enabled = !@enabled
    for win in safari.application.browserWindows
      for tab in win.tabs
        @sendStatus tab.page

  lookup: (word, page) ->
    if @enabled
      if @queryWord != word
        @queryWord = word
      @result = @queryWord #TODO query real results
      page.dispatchMessage "showResult", { word: @queryWord, result: @result }

  status: (page) ->
    @sendStatus page

Safarikai.initialize()

Commands =
  toggle:
    invoke: (event) ->
      Safarikai.toggle()
      event.target.validate()
    validate: (event) ->
      event.target.toolTip  = if Safarikai.enabled then "Disable Safarikai" else "Enable Safarikai"
      event.target.image    = safari.extension.baseURI + (if Safarikai.enabled then "IconEnabled.png" else "IconDisabled.png")

safari.application.addEventListener "command", (e) ->
  Commands[e.command]?.invoke?(e)

safari.application.addEventListener 'validate', (e) ->
  Commands[e.command]?.validate?(e)

safari.application.addEventListener "message", (e) ->
  messageName = e.name
  messageData = e.message
  switch messageName
    when "lookupWord" then Safarikai.lookup messageData, e.target.page
    when "queryStatus" then Safarikai.status e.target.page

console.log "Safarikai global script booted."

Safarikai =
  initialize: ->
    @enabled   = false
    @queryWord = ""
    @result    = ""

  sendStatus: (page) -> page.dispatchMessage "status", enabled: @enabled, highlightText: safari.extension.settings.highlightText

  toggle: ->
    @enabled = !@enabled
    @prepareDictionary()
    @updateStatus()

  lookup: (word, url, page) ->
    if @enabled
      if @queryWord isnt word
        @queryWord = word
        @result = @dict.find @queryWord
      page.dispatchMessage "showResult", word: @queryWord, url: url, result: @result

  status: (page) -> @sendStatus page

  updateStatus: ->
    for win in safari.application.browserWindows
      @sendStatus tab.page for tab in win.tabs

  prepareDictionary: ->
    if @enabled
      @dict ||= new Dictionary
      @dict.load()
    else
      @dict?.unload()
      @dict = null

Safarikai.initialize()

safari.application.addEventListener "command", (e) ->
  Commands[e.command]?.invoke?(e)

safari.application.addEventListener 'validate', (e) ->
  Commands[e.command]?.validate?(e)

safari.extension.settings.addEventListener "change", (e) ->
  Safarikai.updateStatus()

safari.application.addEventListener "message", (e) ->
  messageData = e.message
  switch e.name
    when "lookupWord" then Safarikai.lookup messageData.word, messageData.url, e.target.page
    when "queryStatus" then Safarikai.status e.target.page

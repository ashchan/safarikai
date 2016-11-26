window.Safarikai =
  initialize: ->
    @queryWord = ""
    @result    = ""

  sendStatus: (page) ->
    page.dispatchMessage "status", enabled: @enabled(), highlightText: @highlightText(), showRomaji: @showRomaji(), showTranslation: @showTranslation()

  highlightText: ->
    true

  enabled: ->
    true
    #safari.extension.settings.enabled is 'on'

  showRomaji: ->
    true
    #safari.extension.settings.showRomaji is 'on'

  showTranslation: ->
    true
    #safari.extension.settings.showTranslation is 'on'

  toggle: ->
    #todo
    #safari.extension.settings.enabled = if @enabled() then 'off' else 'on'
    @updateStatus()

  resultsLimit: ->
    5

  lookup: (word, url, page) ->
    if @enabled()
      if @queryWord isnt word
        @queryWord = word
        @result = @dict.find @queryWord, @resultsLimit()
      page.dispatchMessage "showResult", word: @result.match, url: url, result: @result.results

  status: (page) -> @sendStatus page

  updateStatus: ->
    @prepareDictionary()
    for win in safari.application.browserWindows
      @sendStatus tab.page for tab in win.tabs

  prepareDictionary: ->
    if @enabled()
      @dict ||= new Dictionary
      @dict.load()
    else
      @dict?.unload()
      @dict = null

Safarikai.initialize()
Safarikai.prepareDictionary()

#safari.application.addEventListener "command", (e) ->
  #Commands[e.command]?.invoke?(e)

#safari.application.addEventListener 'validate', (e) ->
  #Commands[e.command]?.validate?(e)

#safari.extension.settings.addEventListener "change", (e) ->
  #Safarikai.updateStatus()

#safari.application.addEventListener "message", (e) ->
  #messageData = e.message
  #switch e.name
    #when "lookupWord" then Safarikai.lookup messageData.word, messageData.url, e.target.page
    #when "queryStatus" then Safarikai.status e.target.page

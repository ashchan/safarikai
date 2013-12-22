class Dictionary
  constructor: -> console.log "Create dictionary instance"

  find: (word) ->
    return [] unless @index and @dict
    indexes = @index[word] || []
    @findItemsByIndexes indexes

  findItemsByIndexes: (indexes) -> @findItemByIndex i for i in indexes

  findItemByIndex: (i) ->
    start = 0
    stop  = @dict.length - 1
    pivot = Math.floor (start + stop) / 2

    while @dict[pivot][0] isnt i and start < stop
      stop  = pivot - 1 if i < @dict[pivot][0]
      start = pivot + 1 if i > @dict[pivot][0]
      pivot = Math.floor (stop + start) / 2

    item = @dict[pivot]
    kana:  item[1], kanji: item[2], translation: item[3]

  load: ->
    @readDataFile "index.js", (data) =>
      eval data # var loadedIndex = {...}
      @index = loadedIndex
    @readDataFile "dict.js", (data) =>
      eval data # var loadedDict = []
      @dict = loadedDict

  unload: ->
    @index = null
    @dict  = null

  readDataFile: (file, success) ->
    req = new XMLHttpRequest()
    req.open "GET", safari.extension.baseURI + "data/" + file, true
    req.onload = (e) -> success req.responseText if req.readyState is 4
    req.send null

Safarikai =
  initialize: ->
    @enabled   = false
    @queryWord = ""
    @result    = ""

  sendStatus: (page) -> page.dispatchMessage "status", enabled: @enabled

  toggle: ->
    @enabled = !@enabled
    @prepareDictionary()

    for win in safari.application.browserWindows
      @sendStatus tab.page for tab in win.tabs

  lookup: (word, url, page) ->
    if @enabled
      if @queryWord isnt word
        @queryWord = word
        @result = @dict.find @queryWord
      page.dispatchMessage "showResult", word: @queryWord, url: url, result: @result

  status: (page) -> @sendStatus page

  prepareDictionary: ->
    if @enabled
      @dict ||= new Dictionary
      @dict.load()
    else
      @dict?.unload()
      @dict = null

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
  messageData = e.message
  switch e.name
    when "lookupWord" then Safarikai.lookup messageData.word, messageData.url, e.target.page
    when "queryStatus" then Safarikai.status e.target.page

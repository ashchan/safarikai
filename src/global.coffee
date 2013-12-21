class Dictionary
  constructor: ->
    console.log "Create dictionary instance"

  find: (word) ->
    indexes = @index?[word] || []
    @findItemsByIndexes indexes

  findItemsByIndexes: (indexes) ->
    @findItemByIndex i for i in indexes

  findItemByIndex: (i) ->
    start = 0
    stop  = @dict.length - 1
    pivot = Math.floor (start + stop) / 2

    while @dict[pivot][0] isnt i and start < stop
      stop  = pivot - 1 if i < @dict[pivot][0]
      start = pivot + 1 if i > @dict[pivot][0]
      pivot = Math.floor (stop + start) / 2

    item = @dict[pivot]
    {
      kana:  item[1],
      kanji: item[2],
      translation: item[3]
    }

  load: ->
    eval @readDataFile("index.js") # @index
    eval @readDataFile("dict.js")  # @dict

  unload: ->
    @index = null
    @dict  = null

  readDataFile: (file) ->
    req = new XMLHttpRequest()
    req.open "GET", safari.extension.baseURI + "data/" + file, false
    req.send null
    req.responseText

Safarikai =
  initialize: ->
    @enabled   = false
    @queryWord = ""
    @result    = ""

  sendStatus: (page) ->
    page.dispatchMessage "status", { enabled: @enabled }

  toggle: ->
    @enabled = !@enabled
    @prepareDictionary()

    for win in safari.application.browserWindows
      for tab in win.tabs
        @sendStatus tab.page

  lookup: (word, page) ->
    if @enabled
      if @queryWord != word
        @queryWord = word
      @result = @dict.find @queryWord
      page.dispatchMessage "showResult", { word: @queryWord, result: @result }

  status: (page) ->
    @sendStatus page

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
  messageName = e.name
  messageData = e.message
  switch messageName
    when "lookupWord" then Safarikai.lookup messageData, e.target.page
    when "queryStatus" then Safarikai.status e.target.page

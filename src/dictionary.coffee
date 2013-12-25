class window.Dictionary
  constructor: -> console.log "Create dictionary instance"

  find: (word) ->
    return [] unless @index and @dict

    results = []
    for w in (word.substring 0, l for l in [word.length..1])
      results = results.concat @searchWord w
    console.log results
    results

  searchWord: (word) ->
    results = []
    for variant in Deinflector.deinflect word
      results = results.concat @searchItemsByIndexes @index[variant]
    results

  searchItemsByIndexes: (indexes = []) ->
    @searchItemByIndex i for i in indexes

  searchItemByIndex: (i) ->
    start = 0
    stop  = @dict.length - 1
    pivot = Math.floor (start + stop) / 2

    while @dict[pivot][0] isnt i and start < stop
      stop  = pivot - 1 if i < @dict[pivot][0]
      start = pivot + 1 if i > @dict[pivot][0]
      pivot = Math.floor (stop + start) / 2

    item = @dict[pivot]
    kana: item[1], kanji: item[2], translation: item[3], romaji: Romaji.toRomaji item[1]

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

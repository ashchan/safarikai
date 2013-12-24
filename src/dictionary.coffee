class window.Dictionary
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
    kana: item[1], kanji: item[2], translation: item[3], romaji: toRomaji item[1]

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

class window.Dictionary
  constructor: -> console.log "Create dictionary instance"

  find: (word, limit) ->
    return [] unless @dict

    longest = null
    results = []
    for w in (word.substring 0, l for l in [word.length..1])
      result = @searchWord w
      longest or= w if result.length > 0
      results.push result...
    results: (result for result, idx in results when idx < limit), match: longest

  searchWord: (word) ->
    results = []
    for variant in Deinflector.deinflect word
      item = @dict.words[variant]
      results.push @parseResult variant, result for result in item if item
      indexes = @dict.indexes[variant]
      if indexes
        for index in indexes
          item = @dict.words[index]
          results.push @parseResult index, result for result in item if item
    results

  parseResult: (kanji, result) ->
    if result[0] is "["
      parts = result.split /[\[\]]/
      kana = parts[1]
      translation = parts[2].substring 1
    else
      kana = kanji
      translation = result

    translation = translation.replace /^\/\(\S+\) /, ""
    translation = translation.replace /\(P\)\/$/, ""
    translation = translation[0..-2].split("/").join "; "

    { kana: kana, kanji: kanji, translation: translation, romaji: Romaji.toRomaji kana }

  load: ->
    readDataFile "dictionary.js", (data) =>
      eval data # var loadedDict = {}
      @dict = loadedDict

  unload: ->
    @dict  = null

flatten = (array) ->
  flattened = []
  for element in array
    if element instanceof Array
      flattened.push flatten(element)...
    else
      flattened.push element
  flattened

readDataFile = (file, success) ->
  req = new XMLHttpRequest()
  req.open "GET", safari.extension.baseURI + "data/" + file, true
  req.onload = (e) -> success req.responseText if req.readyState is 4
  req.send null

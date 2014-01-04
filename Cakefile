{spawn} = require 'child_process'
fs = require 'fs'

distDir = "Safarikai.safariextension/"

task 'build', 'Build from src', ->
  buildDependenceFiles()
  buildLocalFiles()

task 'seed', 'Generate data', ->
  generateData()

buildDependenceFiles = ->
  depFiles = ("node_modules/japanese-kit/src/#{file}.coffee" for file in ["romaji", "deinflect"])
  coffee = spawn "coffee", ["-c", "-o", distDir].concat depFiles
  coffee.on 'error', (error) ->
    process.stderr.write error.toString() + "\n"

buildLocalFiles = ->
  coffee = spawn "coffee", ["-c", "-o", distDir, "src"]
  coffee.on 'error', (error) -> process.stderr.write error.toString() + "\n"

generateData = ->
  data = fs.readFileSync "data/dict.dat", "utf8"
  indexes = fs.readFileSync "data/dict.idx", "utf8"

  recordLine = (line) ->
    columns = line.split ","
    word = columns[0]
    offsets = columns[1..-1]
    dictionary[word] or= []
    for offset in offsets
      item = data.substring offset, data.indexOf "\n", offset
      dictionary[word].push item.replace "[#{word}]", ""

  dictionary = {}
  recordLine line for line in indexes.split "\n"

  fs.writeFileSync "Safarikai.safariextension/data/dictionary.js", "var loadedDict = #{JSON.stringify dictionary};"

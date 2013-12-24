{spawn} = require 'child_process'

distDir = "Safarikai.safariextension/"

task 'build', 'Build from src', ->
  buildDependenceFiles()
  buildLocalFiles()

buildDependenceFiles = ->
  depFiles = ("node_modules/japanese-kit/src/#{file}.coffee" for file in ["romaji", "deinflect"])
  coffee = spawn "coffee", ["-c", "-o", distDir].concat depFiles
  coffee.on 'error', (error) ->
    process.stderr.write error.toString() + "\n"

buildLocalFiles = ->
  coffee = spawn "coffee", ["-c", "-o", distDir, "src"]
  coffee.on 'error', (error) -> process.stderr.write error.toString() + "\n"

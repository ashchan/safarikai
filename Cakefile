{spawn} = require 'child_process'

distDir = "Safarikai.safariextension/"

task 'build', 'Build from src', ->
  buildGlobalScript()
  buildInjectedScript()

buildGlobalScript = ->
  files = ["dictionary", "romaji", "commands", "global"]
  coffee = spawn "coffee", ["-j", "global.js", "-c", "-o", distDir].concat ("src/#{file}.coffee" for file in files)
  coffee.on 'error', (error) ->
    process.stderr.write error.toString() + "\n"

buildInjectedScript = ->
  coffee = spawn "coffee", ["-c", "-o", distDir, "src/injected.coffee"]
  coffee.on 'error', (error) ->
    process.stderr.write error.toString() + "\n"

{spawn} = require 'child_process'
fs = require 'fs'

task 'build', 'Build from src', ->
  coffee = spawn "coffee", ["-c", "-o", "Safari\ Extension", "coffee"]
  coffee.on 'error', (error) -> process.stderr.write error.toString() + "\n"


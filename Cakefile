{print} = require 'util'
{spawn} = require 'child_process'

task 'build', 'Build from src', ->
  coffee = spawn 'coffee', ['-c', '-o', 'Safarikai.safariextension', 'src']
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    print data.toString()
  coffee.on 'exit', (code) ->
    callback?() if code is 0

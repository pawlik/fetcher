repository_url = 'git@github.com:pawlik/centrum_faktur'
clone_to = "/tmp/cf"

path = require 'path'
tmp_path = path.join("/tmp/", repository_url)

spawn = require('child_process').spawn

events = require('events')
emitter = new events.EventEmitter()

console.log(tmp_path);

fs = require 'fs'


isTmpPresent = ()->
  try
    fs.accessSync tmp_path
    return true
  catch e
    switch true
      when e.code == 'ENOENT' then return false
      else throw e


clone_shallow = (from, to) ->
  clone = spawn "git", ['clone', from, to, '--depth',  '1']
  clone.stderr.on 'data', (data)-> console.error(data.toString())
  clone.stdout.on 'data', (data)-> console.log(data.toString())
  clone.on 'close', (code) ->
    return emitter.emit 'code_fetched' if code == 0
    throw "clone shallow error, code returned: "+code

if isTmpPresent()
  clone_shallow tmp_path, clone_to
  console.log("change origin remote to URL")
else
  clone_shallow repository_url, clone_to
  console.log "make tmp from shallow clone"
  console.log "unshallow tmp"
  console.log "unshallow working dir"
  console.log "change origin to URL"
  console.log "add remote tmp pointing to tmp (not sure why ;))"






#
#
#clone = spawn('git'
#  [
#    'clone'
#    'git@github.com:pawlik/N3'
#    '--depth', '1'
#  ]
#)
#
#clone.stderr.on 'data', (data)->
#  console.error('error: ' + data)
#
#clone.stdout.on 'data', (data)->
#  console.log('stdout: ' + data)
#
#clone.on 'close', (code)->
#  console.log("Child ended with code " + code)

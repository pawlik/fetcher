Promise = require 'promise-js'

repository_url = 'git@github.com:pawlik/centrum_faktur'
clone_to = "/tmp/cf"

path = require 'path'
tmp_path = path.join("/tmp/", repository_url)

spawn = require('child_process').spawn

events = require('events')
emitter = new events.EventEmitter()


fs = require 'fs'


isTmpPresent = ()->
  try
    fs.accessSync tmp_path
    return true
  catch e
    switch true
      when e.code == 'ENOENT' then return false
      else throw e



#
clone_shallow = (from, to) ->
  return console.log("> clone shallow from " + from + " to " + to)
  clone = spawn "git", ['clone', from, to, '--depth',  '1']
  clone.stderr.on 'data', (data)-> console.error(data.toString())
  clone.stdout.on 'data', (data)-> console.log(data.toString())
  clone.on 'close', (code) ->
    return emitter.emit 'codeFetched' if code == 0
    throw "clone shallow error, code returned: "+code
#
clone_mirror = (from, to) ->
  return console.log "> clone mirror from " + from + "tp " + to
#  clone = spawn "git", ['clone', from, to, '--mirror']
#  clone.stderr.on 'data', (data)-> console.error(data.toString())
#  clone.stdout.on 'data', (data)-> console.log(data.toString())
#  clone.on 'close', (code) ->
#    return emitter.emit 'tmpExists' if code == 0
#    throw "clone tmp error, code returned: "+code

if isTmpPresent()
  tmp_updated = new Promise (resolve)-> console.log("> updating tmp mirror"); resolve(true)
  code_cloned = new Promise (resolve)-> tmp_updated.then ()-> clone_shallow(tmp_path, clone_to); resolve(true)
else
  code_cloned = new Promise ()-> clone_shallow(repository_url, clone_to)
  tmp_ready = new Promise ()->
    clone_mirror clone_to, tmp_path
    console.log "> switch " + tmp_path + " remote to " + repository_url
    console.log "> fetch --unshallow "
    console.log "> make " + clone_to + "remote origin set to " + repository_url
    console.log "> add remote 'tmp':" + tmp_path
    consol.elog "> git fetch tmp --unshallow to unshallow code repo"



#  emitter.on "codeFetched", ()->
#    clone_mirror clone_to, tmp_path
#
#  console.log "make tmp from shallow clone"
#  console.log "unshallow tmp"
#  console.log "unshallow working dir"
#  console.log "change origin to URL"
#  console.log "add remote tmp pointing to tmp (not sure why ;))"






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

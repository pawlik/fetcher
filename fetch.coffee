Promise = require 'promise-js'

repository_url = 'git@github.com:pawlik/centrum_faktur'
clone_to = "/tmp/fetcher_cf"

path = require 'path'
tmp_path = path.join("/tmp/fetcher", repository_url)

spawn = require('child_process').spawn
child_process = require('child_process')

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
clone_shallow = (from, to, callback) ->
  console.log("> clone shallow from " + from + " to " + to)
  clone = spawn "git", ['clone', from, to, '--depth',  '1']
  clone.stderr.on 'data', (data)-> console.error(data.toString())
  clone.stdout.on 'data', (data)-> console.log(data.toString())
  clone.on 'close', (code) ->
    return callback(code) if code == 0
    throw "clone shallow error, code returned: "+code
#
clone_mirror = (from, to, repo_url, callback) ->
  console.log "> clone mirror from " + from + " to " + to
  clone = spawn "git", ['clone', from, to, '--mirror']
  clone.stderr.on 'data', (data)-> console.error(data.toString())
  clone.stdout.on 'data', (data)-> console.log(data.toString())
  clone.on 'close', (code) ->
    if code == 0
      console.log "> do important stuff"
      child_process.spawnSync "git", ["remote", "set-url", "origin", repo_url], {cwd: to}
      child_process.spawnSync "git", ["fetch", "origin", "--unshallow"], {cwd: to}
      return callback(code)
    throw "clone tmp error, code returned: "+code

if isTmpPresent()
  tmp_updated = new Promise (resolve)-> console.log("> updating tmp mirror"); resolve(true)
  code_cloned = new Promise (resolve)-> tmp_updated.then ()-> clone_shallow(tmp_path, clone_to, resolve)
else
  code_cloned = new Promise (resolve)-> clone_shallow(repository_url, clone_to, resolve)

  tmp_ready = code_cloned.then ()->
    # below should be detachable process
    # https://iojs.org/api/child_process.html#child_process_options_detached
    return new Promise (resolve)-> clone_mirror clone_to, tmp_path, repository_url, resolve

  tmp_ready.then ()->
    child_process.spawnSync "git", ["remote", "add", "tmp", tmp_path], {cwd: clone_to}
    child_process.spawnSync "git", ["fetch", "tmp", "--unshallow"], {cwd: clone_to}


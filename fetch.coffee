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
  clone = spawn "git", ['clone', from, to, '--depth',  '1', '--progress'], {
    stdio: ['ignore', process.stdout, process.stderr]
  }
  clone.stderr.on 'data', (data)-> console.error(data.toString())
  clone.stdout.on 'data', (data)-> console.log(data.toString())
  clone.on 'close', (code) ->
    return callback(code) if code == 0
    throw "clone shallow error, code returned: "+code

if isTmpPresent()
  tmp_updated = new Promise (resolve)-> console.log("> updating tmp mirror"); resolve(true)
  code_cloned = new Promise (resolve)-> tmp_updated.then ()-> clone_shallow(tmp_path, clone_to, resolve)
else
  code_cloned = new Promise (resolve)-> clone_shallow(repository_url, clone_to, resolve)

  tmp_ready = code_cloned.then ()->
    fs = require "fs"
    command = "./make_tmp_and_unshallow.sh"
    out = fs.openSync command + ".log", 'a'
    err = fs.openSync command + ".log", 'a'
    child = spawn command, [repository_url, tmp_path, clone_to], {
      detached: true
      stdio: ['ignore', out, err]
    }
    child.unref()



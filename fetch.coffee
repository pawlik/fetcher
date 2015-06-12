Promise = require 'promise-js'

path = require 'path'

spawn = require('child_process').spawn
spawnSync = require('child_process').spawnSync
child_process = require('child_process')

events = require('events')
emitter = new events.EventEmitter()


argv = require('minimist')(process.argv.slice(2), {
  boolean: ['help']

})
usage = "
Usage:\n
iojs #{process.argv[1]} <repository> <directory>
\noptions:
\n
--help\t\t show this help
"
console.log usage if argv.help

repository_url = argv._[0]
clone_to = argv._[1]

console.log repository_url, clone_to

tmp_path = path.join("/tmp/fetcher", repository_url)

fs = require 'fs'


isTmpPresent = ()->
  try
    fs.accessSync tmp_path
    return true
  catch e
    switch true
      when e.code == 'ENOENT' then return false
      else
        throw e

_stdio = ['ignore', process.stdout, process.stderr]

clone_shallow = (from, to, callback) ->
  console.log("> clone shallow from " + from + " to " + to)
  clone = spawn "git", ['clone', from, to, '--depth', '1', '--progress'], {
    stdio: _stdio
  }
  clone.on 'close', (code) ->
    return callback(code) if code == 0
    throw "clone shallow error, code returned: " + code

clone = (from, to, callback) ->
  console.log("> clone from " + from + " to " + to)
  clone = spawn "git", ['clone', from, to, '--progress'], {
    stdio: _stdio
  }
  clone.on 'close', (code) ->
    return callback(code) if code == 0
    throw "clone shallow error, code returned: " + code

if isTmpPresent()
  tmp_updated = new Promise (resolve)->
    console.log "> update tmp mirror"
    child = spawn "git", ["remote", "update"], {
      stdio: _stdio
      cwd: tmp_path
    }
    child.on 'close', (code)->
      return resolve(code) if code == 0
      throw "tmp update error, code returned: " + code
  code_cloned = new Promise (resolve)->
    tmp_updated.then ()-> clone(tmp_path, clone_to, resolve)
  code_cloned.then ()->
    console.log "code cloned"
    spawnSync "git", ["remote", "rename", "origin",
                      "tmp"], {cwd: clone_to, stdio: _stdio}
    spawnSync "git", ["remote", "add", "origin",
                      repository_url], {cwd: clone_to, stdio: _stdio}
else
  code_cloned = new Promise (resolve)-> clone_shallow(repository_url, clone_to,
    resolve)

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



Promise = require 'promise-js'

path = require 'path'

spawn = require('child_process').spawn
spawnSync = require('child_process').spawnSync
child_process = require('child_process')

events = require('events')
emitter = new events.EventEmitter()

exports.run = (repository_url, clone_to, argv)->

  tmp_path = path.join("/tmp/fetcher", repository_url)

  fs = require 'fs'


  isTmpPresent = ()->
    try
      # older versions of iojs/node doesn't have accessSync yet
      # on the other hand - existsSync will be depracated
      if fs.accessSync
        fs.accessSync tmp_path
      else
        return fs.existsSync tmp_path
      return true
    catch e
      switch true
        when e.code == 'ENOENT' then return false
        else
          throw e

  _stdio = ['ignore', process.stdout, process.stderr]

  clone_shallow = (from, to, extraParams=[], callback) ->
    console.log("> clone shallow from " + from + " to " + to)
    params = ['clone', from, to, '--depth', '1', '--progress']
    params = params.concat(extraParams)
    clone = spawn "git", params, {
      stdio: _stdio
    }
    clone.on 'close', (code) ->
      return callback(code) if code == 0
      throw "clone shallow error, code returned: " + code

  clone = (from, to, extraParams=[], callback) ->
    console.log("> clone from " + from + " to " + to)
    params = ['clone', from, to, '--progress']
    params = params.concat(extraParams)
    clone = spawn "git", params, {
      stdio: _stdio
    }
    clone.on 'close', (code) ->
      return callback(code) if code == 0
      throw "clone shallow error, code returned: " + code


  cloneParams = []
  cloneParams = ['--branch', argv.branch ] if argv.branch

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
      tmp_updated.then ()-> clone(tmp_path, clone_to, cloneParams, resolve)
    code_cloned.then ()->
      console.log "code cloned"
      spawnSync "git", ["remote", "rename", "origin",
                        "tmp"], {cwd: clone_to, stdio: _stdio}
      spawnSync "git", ["remote", "add", "origin",
                        repository_url], {cwd: clone_to, stdio: _stdio}
      spawnSync "git", [
        "config",
        "--replace-all",
        "remote.origin.fetch",
        "+refs/heads/*:refs/remotes/origin/*"
      ], {cwd: clone_to}
      spawnSync "git", ["fetch", "origin"], {cwd: clone_to}
  else
    code_cloned = new Promise (resolve)-> clone_shallow(
      repository_url, clone_to, cloneParams, resolve)

    tmp_ready = code_cloned.then ()->
      fs = require "fs"
      command = "./make_tmp_and_unshallow.sh"
      out = fs.openSync command + ".log", 'a'
      err = fs.openSync command + ".log", 'a'
      child = spawn command, [repository_url, tmp_path, clone_to], {
        detached: true
        stdio: ['ignore', out, err]
      }
      console.log(
        "> local mirror repo (#{tmp_path}) will be created in the background
            \n\t\tboth #{tmp_path} and #{clone_to} will be unshallowed afterwards
            \n\t\tyou can watch progress with tail -f #{command}.log
            \n\t\tyou can use your code as soon as this script exits
        "
      )
      child.unref()



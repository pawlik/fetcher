Promise = require "promise-js"


exports.Lane = ()->
  console.log arguments
  this.run = ()-> console.log "run"



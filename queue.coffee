

lane_fetch_repo = new Lane(
  ()-> console.log "fetch shallow"
).go() # those will be run pararell, start immediatelly

lane_load_dump = new Lane(
  ()-> console.log "dump"
).go()

lane_dependencies = new Lane(
  [
    ()-> console.log "composer install"
    ()-> console.log "bower install"
  ]
).waitFor(lane_fetch_repo) # waits, then runs both instances in pararell



lane_unshallow = new Lane(
  ()-> console.log "make mirrow temp from repo"
  ()-> console.log "switch mirrot remote to url"
  ()-> console.log "mirror fetch --unshallow"
  ()-> console.log "reneme cloned repo to tmp"
  ()-> console.log "add remote to cloned repo"
  ()-> console.log "fetch tmp --unshallow"
).detached().waitFor(lane_fetch_repo)
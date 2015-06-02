assert = require "assert"

Lane = require("../lib/lane").Lane

describe "test", ()->
  it "does somethind", ()->
    done_jobs = []

    doneJob1 = () ->
      done_jobs.push("job1")

    doneJob2 = () ->
      done_jobs.push("job2")

    lane = new Lane(
      [
        () -> setTimeout doneJob1, 10
        () -> setTimeout doneJob2, 50
      ]
    )
    console.log(lane.run)
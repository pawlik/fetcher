#!/usr/bin/env bash

# allows simple callback registration through named pipe
# @arg first argument should be path to pipe (made via mkfifo)
# @arg second is command (or string in more complicated examples like)
# example:
#    register_listener /tmp/mypipe 'echo "my event was fired! yay pipes!"'
# Important: this works in LIFO order, also pipe works only as a communication
# of ended process - one should not depend on transfered there
register_listener()
{
pipe=$1
command=$2

if [ -p $pipe ]; then
    # pipe was released already, fire up!
    $command < $pipe # wait for pipe
else
    $command
fi
}
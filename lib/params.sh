#!/usr/bin/env bash

while test $# -gt 0; do
    case "$1" in
        -r|--repository)
            shift
            export REPOSITORY_URL=$1
            shift
            ;;
        -b|--branch)
            shift
            export BRANCH=$1
            shift
            ;;
        --unshallow)
            shift
            export unshallow=$1
            shift
            ;;
        *)
            break
            ;;
    esac
done


fail=0

if [ -z "$REPOSITORY_URL" ]; then
    echo "need repository (-r)"
    fail=1
fi


if [ -z "$BRANCH" ]; then
    echo "assuming branch 'master'"
    BRANCH='master'
fi

if [[ $fail > 0 ]]; then
  exit $fail
fi
#!/usr/bin/env bash


workinng_dir=$( pwd )
source ./lib/params.sh
source ./lib/pipes.sh

tmp_dir=$(mktemp -d)
export SHALLOW_CLONE_READY=$tmp_dir"/shallow_clone_pipe"
mkfifo $SHALLOW_CLONE_READY

SETUP_DIR_LINK=$workinng_dir"/app"

fetcher_user_cache=$HOME"/.fetcher"
repos_tmp_dir=$fetcher_user_cache"/repos_tmp"

mkdir -p $fetcher_user_cache
mkdir -p $repos_tmp_dir


repo_tmp=$repos_tmp_dir"/"$( echo $REPOSITORY_URL | sed 's/[^a-z^0-9^A-Z]/'$2'/g' | tr '[:upper:]' '[:lower:]' )

shallow_clone_from_url()
{
    echo "** cloning from "$REPOSITORY_URL
    git clone -b $BRANCH --single-branch --recursive --depth 1 \
        $REPOSITORY_URL $SETUP_DIR_LINK
    echo $? > $SHALLOW_CLONE_READY
    rm $SHALLOW_CLONE_READY
}

clone_from_tmp()
{
    echo "** cloning from "$repo_tmp
    git clone -b $BRANCH --recursive "file://"$repo_tmp $SETUP_DIR_LINK
    echo $? > $SHALLOW_CLONE_READY &
    rm $SHALLOW_CLONE_READY
}

make_tmp_from_clone()
{
    git clone --mirror $SETUP_DIR_LINK $repo_tmp
    cd $repo_tmp
    git remote set-url origin $REPOSITORY_URL
    cd $SETUP_DIR_LINK
    git remote set-url origin "file://"$repo_tmp
}


if [ -d "$repo_tmp" ]; then
    clone_from_tmp &
else
    shallow_clone_from_url &
    register_listener $SHALLOW_CLONE_READY make_tmp_from_clone &
fi


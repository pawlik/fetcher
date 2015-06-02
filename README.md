# fetcher
The main goal of this tool is to provide a fast way for cloning big repositories. It's focus is to bring 
code as soon as possible, so you can continue in build script inside your repo (this is achieved by making
so called shallow repo). 

The problem with shallow repo is - it's pain in the ass for developers. Only few commits are available in git log
(in case of fetcher only one), and git blame gives you wrong answers. So we try to unshallow repo for you.

## How is it achieved

There are two scenarios.

### 1. very first run ever
* With the very first run it clones shallow repo from URL, then script exits. So you can call command 
to build your app. 
* before the scripts exits, though, it calls detached process which
    * creates tmp mirror repo
    * unshallows this repo 
    * reassigns remotes on just cloned repo, and unshallows it
    
### 2. next run
* your tmp mirror is here, so it just updates it
* clones your repo from tmp instead url
* reassigns remotes, so you can push your work to origin (instead of tmp mirror)
    

# What it can do:
- when there's no tmp repo mirror it'll fetch shallow, repo, then create (also shallow) tmp repo. With `--shallow` it will then unshallow tmp, and then unshallow fetched app. 

# todo
* [ ] test and finish path when there's tmp repo present
* [x] DONE :process dependencies are managed on iojs level: named pipes and paralel tasks make it seems like script hanged n(maybe this can be fixed)
* [ ] could take a look on $HOME/.fetcher and automatically add teammater repos as remotes (just useful)
* [ ] would be nice if it could know it's run on guest machine (Vagrant) and try to use Host tmp repo at first, this would allow utilizing cache even after destroying vagrat machie.


# why not bash?

It's hard to make concurecy and not exit program before most crucial things are done (never sure if its done r not)


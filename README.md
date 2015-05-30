# fetcher
work in progress

# What it can do:
- when there's no tmp repo mirror it'll fetch shallow, repo, then create (also shallow) tmp repo. With `--shallow` it will then unshallow tmp, and then unshallow fetched app. 

# todo
* [ ] test and finish path when there's tmp repo present
* [ ] named pipes and paralel tasks make it seems like script hanged n(maybe this can be fixed)
* [ ] could take a look on $HOME/.fetcher and automatically add teammater repos as remotes (just useful)
* [ ] would be nice if it could know it's run on guest machine (Vagrant) and try to use Host tmp repo at first, this would allow utilizing cache even after destroying vagrat machie.


# why not bash?

It's hard to make concurecy and not exit program before most crucial things are done (never sure if its done r not)


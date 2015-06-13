exports.run = (argv)->
  usage = "
  Usage:\n
  iojs #{process.argv[1]} <repository> <directory> [--branch master]
  \noptions:
  \n--branch\t branch to fetch (like in git clone --branch), default 'master'
  \n--help\t\t show this help
  "
  params = argv.slice(2)

  repository_url = params[0]
  clone_to = params[1]

  argv = require('minimist')(params.slice(2), {
    boolean: ['help']
    string: ['branch'],
    default: {branch: 'master'},
    unknown: (param)->
      console.log "don't know #{param}"
      console.log usage
      process.exit()
  })
  console.log usage if argv.help

  fetcher = require('./fetch')
  console.log(repository_url, clone_to)
  console.dir(argv)
  process.exit();
  fetcher.run(repository_url, clone_to, argv)
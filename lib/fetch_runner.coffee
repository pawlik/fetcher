exports.run = (argv)->
  usage = "
  Usage:\n
  iojs #{process.argv[1]} <repository> <directory> [--branch master]
  \noptions:
  \n--branch\t branch to fetch (like in git clone --branch), default 'master'
  \n--help\t\t show this help
  \n--version\t\t
  "
  params = argv.slice(2)

  repository_url = params[0]
  clone_to = params[1]

  preParse = require('minimist')(argv, {
    boolean: ['version', 'help']
  })

  if preParse.help
    console.log usage
    process.exit()

  if preParse.version
    console.log require('../package').version
    process.exit()

  parsedArgs = require('minimist')(params.slice(2), {
    boolean: ['help', 'version']
    string: ['branch'],
    default: {branch: 'master'},
    unknown: (param)->
      console.log "don't know #{param}"
      console.log usage
      process.exit()
  })

  fetcher = require('./fetch')
  fetcher.run(repository_url, clone_to, argv)
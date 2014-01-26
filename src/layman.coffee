'use strict'

zlib   = require 'zlib'
fs     = require 'fs'

_      = require 'underscore'
app    = require 'commander'
mkdirp = require 'mkdirp'
penman = require 'penman'
knox   = require 'knox'
Q      = require 'q'

util   = require "#{__dirname}/util"

handler = (path) ->
  require "#{process.cwd()}/#{path}"

app
  .version('0.0.1')
  .option('-i --input <S3 bucket>', 'S3 bucket where JSON file lives')
  .option('-o --output <S3 bucket>', 'S3 bucket where CSV file lives')
  .option('-m --mapper <node.js module>', 'mapper, in node.js module', handler)
  .option('-k --keypair <AWS key-pair>', 'aws key-pair', handler)
  .parse(process.argv)

mkdirp.sync './.layman/'

return app.help() unless app.keypair? and app.input? and app.mapper?

client = knox.createClient app.keypair

mapper = app.mapper penman

# Fetch list of target file from S3
Q.ninvoke(client, 'list', {prefix: app.input})
  .get('Contents')
  .then (d) ->
    _.chain(d)
      .pluck('Key')
      .filter (key) ->
        key.match '.gz'
      .value()
  .then (list) ->
    Q.all list.map (path) ->
      [prefix..., fileName] = path.split '/'
      Q.ninvoke(client, 'getFile', path).then (stream) ->
        deferred = do Q.defer
        fileName = fileName.replace /.gz/, '.csv'
        path     = "./.layman/#{fileName}"
        # stream decoding
        stream = stream
          .pipe(zlib.createGunzip())
          .pipe(util.readline())
          .pipe(util.JSONParse())
          .pipe(mapper.stream())
          .pipe(fs.createWriteStream(path))
          .on('error', deferred.reject)
          .once 'end', ->
            deferred.resolve {path, fileName}
        deferred.promise
  .invoke 'map', ({path, fileName}) ->
    Q.ninvoke client, 'putFile', "#{app.output}/#{fileName}"
  .done (results) ->
    console.log 'done with following results'
    console.log JSON.stringify results, null, 4

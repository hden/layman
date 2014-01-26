'use strict'

{Transform} = require 'stream'

class T extends Transform
  constructor: ->
    super
    @_writableState.objectMode = true
    @_readableState.objectMode = true

class Readline extends Transform
  constructor: ->
    super
    @_readableState.objectMode = true
    @_cache = ''

  _transform: (chunk, encoding, done) =>
    @_cache += chunk.toString()
    [lines..., @_cache] = @_cache.split '\n'
    lines
      .filter (line) ->
        line.length > 0
      .forEach @push.bind @
    do done

  _flush: (done) =>
    @push @_cache
    @_cache = ''
    do done

###
Transforming stream factory
Usage
```
transform = require './transform'
inputStream
    .pipe transform (chunk, enc, done) ->
        # do somthing
        do done
    .pipe transform (chunk, enc, done) ->
        # do somthing else
        do done
    .pipe outputStream
```
###

exports.transform = (cb) ->
  stream = new T()
  stream._transform = cb.bind stream
  stream

exports.JSONParse = ->
  exports.transform (line, enc, done) ->
    try
      @push JSON.parse line
    catch e
      # bad JSON
    do done

exports.readline = ->
  new Readline()

'use strict'

module.exports = (mapper) ->
  mapper
    # .map(key, path, defaults, transformer)
    .map('log_id', 'log_id')
    .map('browse_id', 'browse_id')
    .map('ns', 'ns')

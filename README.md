layman
======

Streaming JSON from S3, map to CSV, then streaming back to S3

Installation
------------

    npm install -g hden/layman

Usage
-----

    layman -k awsKey.json -i prefix -o prefix -m mapper

awsKey.json
-----------

    {
      "key": "AWSKEY",
      "secret": "AWSSECRET",
      "bucket": "bucket name"
    }

mapper
-------------

    'use strict';

    module.exports = function(mapper) {
      return mapper
        .map(KEY, PATH, DEFAULTS, TRANSFORMER)
        .map('column1', 'i.can.handle.deep.path', 0)
        .map('column2', 'i.can.even.handle.array[1]', 'default value')
        .map('column3', 'path', 0, function(value) {
          // apply transformation to a value
          return value + 1;
        });
    };

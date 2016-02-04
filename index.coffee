'use strict'

gutil = require('gulp-util')
through = require('through2')
PumlRenderer = require('esf-puml').PumlRenderer
streamBuffers = require('stream-buffers')
stream = require('stream')
path = require('path')


gulpPuml = (opt) ->
  options = opt or format: 'svg'
  ext = options.format if options.format and options.format in ['png','svg','eps']

  through.obj (file, enc, cb) ->
    if file.isNull()
      cb null, file
      return

    rdr = new PumlRenderer
    ccwd = null or options.cwd or path.dirname(file.path)

    if file.isBuffer()
      try
        rdblStmBfr = new (streamBuffers.ReadableStreamBuffer)(
          'frequency': 10
          'chunkSize': 1024 * 4)
        fcnt = file.contents
        file.contents = rdblStmBfr.pipe(rdr.stream(ext, ccwd))
        rdblStmBfr.put fcnt, 'utf8'
        rdblStmBfr.on 'end', ->
          rdblStmBfr.stop()
          return
      catch e
        @emit 'error', new (gutil.PluginError)('gulp-puml', e)
    else if file.isStream()
      try
        file.contents = file.contents.pipe(rdr.stream(ext, ccwd))
      catch e
        @emit 'error', new (gutil.PluginError)('gulp-puml', e)
    if file.path
      file.path = file.path.replace(/\.puml/ig, '.' + ext)
    cb null, file
    return

module.exports = gulpPuml

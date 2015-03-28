angular.module('angular-duration-format.filter', []).filter 'duration', ->
  DURATION_FORMATS_SPLIT = /((?:[^ydhms']+)|(?:'(?:[^']|'')*')|(?:y+|d+|h+|m+|s+))(.*)/
  DURATION_FORMATS = 
    'y': value: 365 * 24 * 60 * 60 * 1000
    'yy':
      value: 'y'
      pad: 2
    'd': value: 24 * 60 * 60 * 1000
    'dd':
      value: 'd'
      pad: 2
    'h': value: 60 * 60 * 1000
    'hh':
      value: 'h'
      pad: 2
    'm': value: 60 * 1000
    'mm':
      value: 'm'
      pad: 2
    's': value: 1000
    'ss':
      value: 's'
      pad: 2
    'sss': value: 1
    'ssss':
      value: 'sss'
      pad: 4

  _parseFormat = (string) ->
    # @inspiration AngularJS date filter
    parts = []
    format = string
    while format
      match = DURATION_FORMATS_SPLIT.exec(format)
      if match
        parts = parts.concat(match.slice(1))
        format = parts.pop()
      else
        parts.push format
        format = null
    parts

  _formatDuration = (timestamp, format) ->
    text = ''
    values = {}
    format.filter((format) ->
      # filter only value parts of format
      DURATION_FORMATS.hasOwnProperty format
    ).map((format) ->
      # get formats with values only
      config = DURATION_FORMATS[format]
      if config.hasOwnProperty('pad')
        config.value
      else
        format
    ).filter((format, index, arr) ->
      # remove duplicates
      arr.indexOf(format) == index
    ).map((format) ->
      # get format configurations with values
      angular.extend { name: format }, DURATION_FORMATS[format]
    ).sort((a, b) ->
      # sort formats descending by value
      b.value - a.value
    ).forEach (format) ->
      # create values for format parts
      value = values[format.name] = Math.floor(timestamp / format.value)
      timestamp = timestamp - value * format.value
      return
    format.forEach (part) ->
      `var format`
      format = DURATION_FORMATS[part]
      if format
        value = values[format.value]
        text += if format.hasOwnProperty('pad') then _padNumber(value, Math.max(format.pad, value.toString().length)) else values[part]
      else
        text += part.replace(/(^'|'$)/g, '').replace(/''/g, '\'')
      return
    text

  _padNumber = (number, len) ->
    (new Array(len + 1).join('0') + number).slice -len

  (value, format) ->
    if typeof value != 'number'
      return value
    timestamp = parseInt(value.valueOf(), 10)
    if isNaN(timestamp)
      value
    else
      _formatDuration timestamp, _parseFormat(format)

angular.module 'angular-duration-format', [ 'angular-duration-format.filter' ]

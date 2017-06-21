EventEmitter = require '../../core/events'
AVBuffer = require '../../core/buffer'

class HTTPSource extends EventEmitter
    constructor: (@url, @opts = {}) ->
        @reset()
        
    start: ->
        @xhr = new XMLHttpRequest()
        @xhr.open('GET', @url, true)
        @xhr.responseType = 'arraybuffer'
        @xhr.onload = (event) =>
            code = (@xhr.status + '')[0]
            if code != '0' && code != '2' && code != '3'
                return @emit 'error', 'Failed loading audio file with status: ' + @xhr.status + '.'

            if @xhr.response
                buf = new Uint8Array(@xhr.response)
            else
                txt = @xhr.responseText
                buf = new Uint8Array(txt.length)
                for i in [0...txt.length]
                    buf[i] = txt.charCodeAt(i) & 0xff

            @emit 'data', new AVBuffer(buf)
            @emit 'end'

        @xhr.onerror = (err) =>
            @emit 'error', err
            @pause()

        @xhr.send(null)

        if @length
            return @loop() unless @inflight
        
    pause: ->
        @xhr?.abort()
        
    reset: ->
        @pause()
        
module.exports = HTTPSource

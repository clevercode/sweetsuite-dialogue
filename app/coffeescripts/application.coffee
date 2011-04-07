class Larynx

  @connect: -> 
    _(this).bindAll('_onmessage', '_onopen', '_onclose', '_onerror')
    @webSocket = new WebSocket('ws://localhost:9000')
    @webSocket.onmessage = @_onmessage
    @webSocket.onopen = @_onopen
    @webSocket.onclose = @_onclose
    @webSocket.onerror = @_onerror

    @webSocket

  @disconnect: ->
    @webSocket.close() if @webSocket

  @send: (obj) ->
    json = JSON.stringify(obj)
    if @webSocket? and @webSocket.readyState is WebSocket.OPEN
      @webSocket.send(json)

  @_onmessage: (messageEvent) ->
    object = JSON.parse(messageEvent.data)
    this.trigger('message', object )
  
  @_onopen: ->
    this.trigger('connect')

  @_onclose: ->
    this.trigger('disconnect', 'OK')

  @_onerror: (error) ->
    this.trigger('disconnect', error)

_(Larynx).extend(Backbone.Events)

window.Larynx = Larynx

class Dialogue
  @VERSION = '0.0.1'
  class @Channel

  class @Message

  class @User

window.Dialogue = Dialogue

jQuery ($)->
  
  #  conversation = new Conversation(22)
  # window.conversation = conversation


    


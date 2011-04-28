SweetSuite = 

  Application:

    boot: null
# Larynx is a wrapper around WebSocket that handles sending and receiving JSON
# serialized objects to and from the Larynx service 
#
Larynx =
  connect: -> 
    _(this).bindAll('_onmessage', '_onopen', '_onclose', '_onerror')
    @webSocket = new WebSocket('ws://localhost:9000')
    @webSocket.onmessage = @_onmessage
    @webSocket.onopen = @_onopen
    @webSocket.onclose = @_onclose
    @webSocket.onerror = @_onerror
    return @webSocket

  disconnect: ->
    @webSocket.close() if @webSocket
    @webSocket = null

  send: (object) ->
    if this.connected?
      @webSocket.send(this.serializeForTransport(object))

  # Returns a JSONified version of the object
  serializeForTransport: (object) ->

    # Give the object a chance to influence its own serialization
    if object.asJson?
      objectForSerialization = object.asJson() 
    else
      objectForSerialization = object

    # Serialize to JSON
    JSON.stringify(objectForSerialization)

  connected: -> 
    @webSocket? and @webSocket.readyState is WebSocket.OPEN


  _onmessage: (messageEvent) ->
    object = JSON.parse(messageEvent.data)
    this.trigger('message', object )
  
  _onopen: ->
    this.trigger('connect')

  _onclose: ->
    this.trigger('disconnect', 'OK')

  _onerror: (error) ->
    this.trigger('disconnect', error)

_(Larynx).extend(Backbone.Events)

window.Larynx = Larynx

class Dialogue


  class @Channel

    constructor: (id) -> 
      null

    join: () ->
      null

    leave: () ->
      null

  class @Message

  class @User

window.Dialogue = Dialogue

class 

jQuery ($)->
  
  #  conversation = new Conversation(22)
  # window.conversation = conversation

  springTop = (y) ->
    scrollView.css({paddingTop: 0-y })

  throttledSpringTop = _(springTop).throttle(100)

  
  scrollView = $('.messagesListView')
  scrollView.bind 'mousewheel', (event) ->
    delta = event.wheelDelta/5
    newY = scrollView.scrollTop() + delta
    console.log((if (delta < 0) then 'up' else 'down'), delta, newY)
    scrollView.scrollTop(newY)
    ###
    if newY < 0
      throttledSpringTop(newY)
    if newY > scrollView.height()
      console.log('bounce')
    ###
    return false
    


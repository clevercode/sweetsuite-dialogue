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

_(Larynx).extend(Jellybean.Events)

window.Larynx = Larynx

Dialogue = {}
class Dialogue.Application

  selector: '#application'

  constructor: () ->
    roomListElement = $('#roomList')[0]
    @roomList = new RoomListViewController(element: roomListElement)
    @roomList.bind 'selection', (selection) => 
      console.log(selection)
      #@roomView.room = selection
    

class RoomListViewController extends Jellybean.TableViewController

  tableStyle: 'JBGroupedTableStyle'

  initialize: ->
    Room.fetch().success =>
      @data = Room.records
      @view.render()

  numberOfRows: ->
    @data.length
  
  cellForRowAtIndex: (index) ->
    cell = new Jellybean.SimpleCellView
    cell.label = @data[index].name
    cell.anchor = @data[index].getUrl()
    cell

  numberOfSections: ->
    2

  titleForSection: (index) ->
    if index == 1 then 'Other Rooms' else 'Active Rooms'

  numberOfRowsInSection: (index) ->
    if index == 1 then 1 else 2

  didSelectIndex: (index) ->
    this.trigger('selection', @data[index])



class RoomViewController
  
  # The room that this controller represents
  room: null

  # The TableView that contains the list of messages
  messagesViewController: null

  # The NewMessageFormView that is at the bottom
  newMessageFormView: null

  initialize: (options) ->
    @room = options.room
    @messagesViewController = new Jellybean.TableViewController(
      cellStyle: MessageCellStyle
      dataSource: @room.messages
    )


Message = class Dialogue.Message extends Jellybean.Model
  @setModelName('Message')
  @setAttributes(['id', 'body', 'user_id'])

Room = class Dialogue.Room extends Jellybean.Model
  @setModelName('Room')
  @setAttributes(['id', 'name', 'topic'])

  @fetch: ->
    $.getJSON('/rooms.json').success( (data) =>
      @records = (Room.inst(obj['room']) for obj in data)
    )

  getUrl: ->
    return "/rooms/#{@id}"

# Export to global scope
@['Dialogue'] = Dialogue

jQuery ($)->
  
  window.dialogue = new Dialogue.Application

  springTop = (y) ->
    scrollView.css({paddingTop: 0-y })

  throttledSpringTop = _(springTop).throttle(100)

  
  scrollView = $('.messagesListView')
  scrollView.bind 'mousewheel', (event) ->
    delta = event.wheelDelta/5
    newY = scrollView.scrollTop() + delta
    #console.log((if (delta < 0) then 'up' else 'down'), delta, newY)
    scrollView.scrollTop(newY)
    ###
    if newY < 0
      throttledSpringTop(newY)
    if newY > scrollView.height()
      console.log('bounce')
    ###
    return false

  
    


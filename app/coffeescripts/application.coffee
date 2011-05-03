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
  @boot: ->
    window.app = new Dialogue.Application()

  selector: '#application'

  constructor: () ->
    roomListElement = $('#roomList')[0]
    $('window').bind 'popstate', (event) =>
      console.log(event)
    @roomList = new RoomListViewController(element: roomListElement)
    @roomList.bind 'selection', (selection) => 
      @roomView.setRoom(selection)
      #this.navigate(selection)
    @roomView = new RoomViewController(element: $('#roomView')[0])

  navigate: (room) ->
    window.history.replaceState({room:room}, room.name, room.getUrl())
    

class RoomListViewController extends Jellybean.TableViewController

  tableStyle: 'JBGroupedTableStyle'

  initialize: ->
    super()
    Room.bind 'refresh', =>
      @data = Room.records()
      @view.render()
      this.restoreSelectedIndex()
    Room.fetch()

  restoreSelectedIndex: ->
    if index = window.localStorage.getItem('roomList.selectedIndex')
      index = parseInt(index, 10)
      @view.setSelectedIndex(index)

  numberOfRows: ->
    @data.length
  
  cellForRowAtIndex: (index) ->
    cell = new Jellybean.TableCell
    cell.label = @data[index].name
    cell

  numberOfSections: ->
    2

  titleForSection: (index) ->
    if index == 1 then 'Other Rooms' else 'Active Rooms'

  numberOfRowsInSection: (index) ->
    if index == 1 then 1 else 2

  didSelectIndex: (index) ->
    this.trigger('selection', @data[index])
    window.localStorage.setItem('roomList.selectedIndex', index)

  didDeselectIndex: (index) ->
    this.trigger('deselection', @data[index])
    window.localStorage.removeItem('roomList.selectedIndex')

class MessagesViewController extends Jellybean.TableViewController

  tableStyle: 'MessagesListStyle'

  initialize: ->
    super()
    @data = Message.records()
    Message.bind('new', (message) =>
      @data.push(message)
      @view.render() 
    )

  titleForSection: (section) ->
    '9:05 AM'

  numberOfRowsInSection: ->
    @data.length

  numberOfRows: ->
    @data.length

  cellForRowAtIndex: (index) ->
    cell = new MessageTableCell
    cell.data = @data[index]
    return cell


class RoomViewController extends Jellybean.ViewController
  
  # The room that this controller represents
  room: null

  roomTitleBar: null
  messagesViewController: null
  composeMessageView: null

  initialize: () ->
    super()
    this.loadView()
    this.setRoom(@options.room || Room.init())

    @messagesViewController = new MessagesViewController(element: @view.$('ul')[0])
    @messagesViewController.delegate = this

  setRoom: (room) ->
    @room = room
    @view.render()

  loadView: ->
    @view = new RoomView(@options.element)
    @view.delegate = this

    @roomTitleBar = new RoomTitleBar()
    @roomTitleBar.delegate = this
    @view.addSubview(@roomTitleBar)

    @messagesViewController = new MessagesViewController(element: @view.$('ul')[0])
    @messagesViewController.delegate = this
    @view.addSubview(@messagesViewController.view)

    @composeMessageView = new ComposeMessageView()
    @view.addSubview(@composeMessageView)
    @composeMessageView.bind('submit', _(@onMessageSubmit).bind(this))

  onMessageSubmit: (text) ->
    Message.create(
      body: text
      user_id: 1
    )

  dataForView: (view) ->
    @room

    

class RoomView extends Jellybean.View
  cssClass: 'roomView'

class RoomTitleBar extends Jellybean.View
  template: Handlebars.compile '''
    <hgroup class="roomInfo">
      <h1>{{ name }}</h1>
      <h2>{{ topic }}</h2>
    </hgroup>
  '''
  render: ->
    content = @template(@delegate.dataForView())
    $(@element).html(content)

class ComposeMessageView extends Jellybean.View
  template: '''
    <form>
      <textarea></textarea>
    </form>
  '''
  initialize: ->
    this.$().addClass('composeMessageView')
    this.$().delegate('textarea', 'keyup', (event) =>
      if event.keyCode is 13
        textarea = this.$('textarea')
        this.trigger('submit', textarea.val())
        textarea.val('')
        return false
    )

  render: ->
    this.$().html(@template)


class MessageTableCell extends Jellybean.TableCell
  tag: 'article'
  template: Handlebars.compile '''  
    <article>
      <div class="user">{{ user/name }}</div>
      <div class="body">{{ body }}</div>
      <footer>
        <ul class="meta">
          <li><time> {{created_at}} </time></li>
          <li><a class="favoriteButton">Favorite</a></li>
          <li><a class="hideButton">Hide</a></li>
        </ul>
      </footer>
    </article>
  '''
  render: ->
    $(@element).html(@template(@data))

Message = class Dialogue.Message extends Jellybean.Model
  @setModelName('Message')
  @setAttributes(['id', 'body', 'user_id'])

  created_at: '10:05'
  user: { name: 'Andrew S.' }

  @FIXTURES: [
    Message.create(id:1, body: 'This is an example message.', user_id: 1),
    Message.create(id:2, body: 'This is another example message.', user_id: 1),
    Message.create(id:3, body: 'This is an example message too.', user_id: 1),
    Message.create(id:4, body: 'This is the last example message.', user_id: 1)
  ]

Room = class Dialogue.Room extends Jellybean.Model
  @setModelName('Room')
  @setAttributes(['id', 'name', 'topic'])


  @fetch: ->
    $.getJSON('/rooms.json').success( (data) =>
      this.refresh((obj['room'] for obj in data))
    )

  initialize: ->
    @name ||= ''
    @topic ||= ''

  getUrl: ->
    return "/rooms/#{@id}"

# Export to global scope
@['Dialogue'] = Dialogue

# Boot on load
jQuery(Dialogue.Application.boot)

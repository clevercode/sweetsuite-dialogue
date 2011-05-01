/* DO NOT MODIFY. This file was compiled Sun, 01 May 2011 08:02:37 GMT from
 * /Users/andrewsmith/sweetsuite/sweetsuite-dialogue/app/coffeescripts/application.coffee
 */

(function() {
  var Dialogue, Larynx, Message, Room, RoomListViewController, RoomViewController;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  Larynx = {
    connect: function() {
      _(this).bindAll('_onmessage', '_onopen', '_onclose', '_onerror');
      this.webSocket = new WebSocket('ws://localhost:9000');
      this.webSocket.onmessage = this._onmessage;
      this.webSocket.onopen = this._onopen;
      this.webSocket.onclose = this._onclose;
      this.webSocket.onerror = this._onerror;
      return this.webSocket;
    },
    disconnect: function() {
      if (this.webSocket) {
        this.webSocket.close();
      }
      return this.webSocket = null;
    },
    send: function(object) {
      if (this.connected != null) {
        return this.webSocket.send(this.serializeForTransport(object));
      }
    },
    serializeForTransport: function(object) {
      var objectForSerialization;
      if (object.asJson != null) {
        objectForSerialization = object.asJson();
      } else {
        objectForSerialization = object;
      }
      return JSON.stringify(objectForSerialization);
    },
    connected: function() {
      return (this.webSocket != null) && this.webSocket.readyState === WebSocket.OPEN;
    },
    _onmessage: function(messageEvent) {
      var object;
      object = JSON.parse(messageEvent.data);
      return this.trigger('message', object);
    },
    _onopen: function() {
      return this.trigger('connect');
    },
    _onclose: function() {
      return this.trigger('disconnect', 'OK');
    },
    _onerror: function(error) {
      return this.trigger('disconnect', error);
    }
  };
  _(Larynx).extend(Jellybean.Events);
  window.Larynx = Larynx;
  Dialogue = {};
  Dialogue.Application = (function() {
    Application.prototype.selector = '#application';
    function Application() {
      var roomListElement;
      roomListElement = $('#roomList')[0];
      this.roomList = new RoomListViewController({
        element: roomListElement
      });
      this.roomList.bind('selection', __bind(function(selection) {
        return console.log(selection);
      }, this));
    }
    return Application;
  })();
  RoomListViewController = (function() {
    function RoomListViewController() {
      RoomListViewController.__super__.constructor.apply(this, arguments);
    }
    __extends(RoomListViewController, Jellybean.TableViewController);
    RoomListViewController.prototype.tableStyle = 'JBGroupedTableStyle';
    RoomListViewController.prototype.initialize = function() {
      return Room.fetch().success(__bind(function() {
        this.data = Room.records;
        return this.view.render();
      }, this));
    };
    RoomListViewController.prototype.numberOfRows = function() {
      return this.data.length;
    };
    RoomListViewController.prototype.cellForRowAtIndex = function(index) {
      var cell;
      cell = new Jellybean.SimpleCellView;
      cell.label = this.data[index].name;
      cell.anchor = this.data[index].getUrl();
      return cell;
    };
    RoomListViewController.prototype.numberOfSections = function() {
      return 2;
    };
    RoomListViewController.prototype.titleForSection = function(index) {
      if (index === 1) {
        return 'Other Rooms';
      } else {
        return 'Active Rooms';
      }
    };
    RoomListViewController.prototype.numberOfRowsInSection = function(index) {
      if (index === 1) {
        return 1;
      } else {
        return 2;
      }
    };
    RoomListViewController.prototype.didSelectIndex = function(index) {
      return this.trigger('selection', this.data[index]);
    };
    return RoomListViewController;
  })();
  RoomViewController = (function() {
    function RoomViewController() {}
    RoomViewController.prototype.room = null;
    RoomViewController.prototype.messagesViewController = null;
    RoomViewController.prototype.newMessageFormView = null;
    RoomViewController.prototype.initialize = function(options) {
      this.room = options.room;
      return this.messagesViewController = new Jellybean.TableViewController({
        cellStyle: MessageCellStyle,
        dataSource: this.room.messages
      });
    };
    return RoomViewController;
  })();
  Message = Dialogue.Message = (function() {
    function Message() {
      Message.__super__.constructor.apply(this, arguments);
    }
    __extends(Message, Jellybean.Model);
    Message.setModelName('Message');
    Message.setAttributes(['id', 'body', 'user_id']);
    return Message;
  })();
  Room = Dialogue.Room = (function() {
    function Room() {
      Room.__super__.constructor.apply(this, arguments);
    }
    __extends(Room, Jellybean.Model);
    Room.setModelName('Room');
    Room.setAttributes(['id', 'name', 'topic']);
    Room.fetch = function() {
      return $.getJSON('/rooms.json').success(__bind(function(data) {
        var obj;
        return this.records = (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = data.length; _i < _len; _i++) {
            obj = data[_i];
            _results.push(Room.inst(obj['room']));
          }
          return _results;
        })();
      }, this));
    };
    Room.prototype.getUrl = function() {
      return "/rooms/" + this.id;
    };
    return Room;
  })();
  this['Dialogue'] = Dialogue;
  jQuery(function($) {
    var scrollView, springTop, throttledSpringTop;
    window.dialogue = new Dialogue.Application;
    springTop = function(y) {
      return scrollView.css({
        paddingTop: 0 - y
      });
    };
    throttledSpringTop = _(springTop).throttle(100);
    scrollView = $('.messagesListView');
    return scrollView.bind('mousewheel', function(event) {
      var delta, newY;
      delta = event.wheelDelta / 5;
      newY = scrollView.scrollTop() + delta;
      scrollView.scrollTop(newY);
      /*
      if newY < 0
        throttledSpringTop(newY)
      if newY > scrollView.height()
        console.log('bounce')
      */
      return false;
    });
  });
}).call(this);

/* DO NOT MODIFY. This file was compiled Sun, 01 May 2011 08:02:37 GMT from
 * /Users/andrewsmith/sweetsuite/jellybean/coffeescripts/jellybean.coffee
 */

(function() {
  var __slice = Array.prototype.slice, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  this['Jellybean'] = (function() {
    var $, Events, Jb, Model, View, ViewController, _;
    Jb = {};
    $ = Jb.$ = this.jQuery;
    _ = Jb._ = this._;
    Events = Jb.Events = {
      bind: function(event_type, callback) {
        var type, types, _base, _i, _len;
        types = event_type.split(' ');
        this._callbacks || (this._callbacks = {});
        for (_i = 0, _len = types.length; _i < _len; _i++) {
          type = types[_i];
          (_base = this._callbacks)[type] || (_base[type] = []);
          this._callbacks[type].push(callback);
        }
        return this;
      },
      unbind: function(event_type, callback) {
        if (!event_type) {
          this._callbacks = {};
          return this;
        }
        if (!callback) {
          delete (this._callbacks[event_type] = []);
          return this;
        }
        return this._callbacks[event_type] = _(this._callbacks[event_type]).without(callback);
      },
      trigger: function() {
        var args, callback, event_type, _i, _len, _ref;
        event_type = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
        if (!this._callbacks) {
          return this;
        }
        if (!this._callbacks[event_type]) {
          return this;
        }
        _ref = this._callbacks[event_type];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          callback = _ref[_i];
          callback.apply(this, args);
        }
        return this;
      }
    };
    Model = Jb.Model = (function() {
      function Model() {}
      Model.prototype.attributes = null;
      Model.prototype.afterInit = function() {
        return null;
      };
      Model.prototype.initWith = function(properties) {
        var attr, attrs, val;
        this.attributes = {};
        if (attrs = properties.attributes) {
          for (attr in attrs) {
            val = attrs[attr];
            this.write(attr, val);
          }
        }
        this._callbacks = {};
        return this;
      };
      Model.prototype.read = function(attr) {
        return this.attributes[attr];
      };
      Model.prototype.write = function(attr, val) {
        this.attributes[attr] = val;
        this.trigger('changed');
        return val;
      };
      Model.prototype.updateAttribute = function(attr, val) {
        this.write(attr, val);
        return this.save();
      };
      Model.prototype.updateAttributes = function(newAttributes) {
        var attr, val;
        for (attr in newAttributes) {
          val = newAttributes[attr];
          this.write(attr, val);
        }
        return this.save();
      };
      Model.prototype.validate = function() {
        this.errors = [];
        return true;
      };
      Model.prototype.save = function() {
        if (this.validate()) {
          this.trigger('update', this);
          this.newRecord = false;
          return true;
        } else {
          this.trigger('error', this, this.errors);
          return false;
        }
      };
      Model.prototype.toJSON = function() {
        return this.attributes;
      };
      Model.prototype.clone = function() {
        return Object.create(this);
      };
      return Model;
    })();
    Model.setModelName = function(name) {
      return this.modelName = name;
    };
    Model.setAttributes = function(attributes) {
      return this.attributes = attributes;
    };
    Model.propertyDescriptors = function() {
      var attribute, descriptors, _fn, _i, _len, _ref;
      descriptors = {};
      _ref = this.attributes;
      _fn = function(attribute) {
        return descriptors[attribute] = {
          get: function() {
            return this.read(attribute);
          },
          set: function(val) {
            return this.write(attribute, val);
          },
          enumerable: true
        };
      };
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        attribute = _ref[_i];
        _fn(attribute);
      }
      descriptors['modelName'] = {
        value: this.modelName,
        writable: false
      };
      return descriptors;
    };
    Model.init = function(attributes) {
      var record;
      record = this.allocate();
      record.initWith({
        attributes: attributes
      });
      record.newRecord = true;
      return record;
    };
    Model.create = function(attributes) {
      var record;
      record = this.init(attributes);
      record.save();
      return record;
    };
    Model.allocate = function() {
      return Object.create(this.prototype, this.propertyDescriptors());
    };
    Model.inst = function(attributes) {
      var record;
      if (!attributes.id) {
        throw "An id is required to reinitialize a record";
      }
      record = this.allocate();
      record.initWith({
        attributes: attributes
      });
      record.newRecord = false;
      return record;
    };
    _(Model.prototype).extend(Events);
    ViewController = Jb.ViewController = (function() {
      function ViewController() {}
      ViewController.prototype.title = null;
      ViewController.prototype.view = null;
      return ViewController;
    })();
    _(ViewController.prototype).extend(Events);
    View = Jb.View = (function() {
      function View(element, options) {
        if (options == null) {
          options = {};
        }
        this.element = element;
        this.options = options;
        this.initialize();
      }
      View.prototype.initialize = function() {
        return null;
      };
      View.prototype.element = null;
      View.prototype.$ = function(selector) {
        return Jb.$(selector || this.element, this.element);
      };
      View.prototype.render = function() {
        return null;
      };
      return View;
    })();
    _(View.prototype).extend(Events);
    Jb.TableViewController = (function() {
      __extends(TableViewController, ViewController);
      TableViewController.prototype.tableStyle = 'JBDefaultTableStyle';
      TableViewController.prototype.currentSelection = null;
      TableViewController.prototype.currentSelectionClassName = 'selected';
      function TableViewController(options) {
        if (options == null) {
          options = {};
        }
        this.data = [];
        this.view = new Jb.TableView(options.element, {
          style: this.tableStyle
        });
        this.view.delegate = this;
        if (this.initialize) {
          this.initialize();
        }
      }
      return TableViewController;
    })();
    Jb.TableView = (function() {
      function TableView() {
        TableView.__super__.constructor.apply(this, arguments);
      }
      __extends(TableView, View);
      TableView.prototype.delegate = null;
      TableView.prototype.currentSelection = null;
      TableView.prototype.visibleCells = null;
      TableView.prototype.template = Handlebars.compile('<li>\n  <h1>{{title}}</h1>\n  <ul></ul>\n</li>');
      TableView.prototype.initialize = function() {
        TableView.__super__.initialize.call(this);
        this.visibleCells = [];
        this.selectedIndex = null;
        Jb.$(this.element).addClass(this.options['style']);
        return this.bindEvents();
      };
      TableView.prototype.bindEvents = function() {
        return $(this.element).delegate('a', 'click', __bind(function(e) {
          e.preventDefault();
          return this.setSelectedIndex(this.$('a').index(e.target));
        }, this));
      };
      TableView.prototype.setSelectedIndex = function(index) {
        if (index === this.selectedIndex) {
          return false;
        }
        if (this.selectedIndex != null) {
          this.visibleCells[this.selectedIndex].setSelected(false);
        }
        this.selectedIndex = index;
        this.visibleCells[this.selectedIndex].setSelected(true);
        this.delegate.didSelectIndex(this.selectedIndex);
        return true;
      };
      TableView.prototype.render = function() {
        var lastRowInSection, renderSection, rowIndex, section, sections;
        rowIndex = 0;
        lastRowInSection = 0;
        renderSection = __bind(function(section) {
          var $section, $sectionList, cell;
          $section = $(this.template({
            title: this.delegate.titleForSection(section)
          }));
          $sectionList = $section.children('ul');
          lastRowInSection += this.delegate.numberOfRowsInSection(section);
          while (rowIndex < lastRowInSection) {
            cell = this.delegate.cellForRowAtIndex(rowIndex);
            cell.render();
            this.visibleCells.push(cell);
            $sectionList.append(cell.element);
            rowIndex++;
          }
          return $section[0];
        }, this);
        sections = (function() {
          var _ref, _results;
          _results = [];
          for (section = 0, _ref = this.delegate.numberOfSections(); (0 <= _ref ? section < _ref : section > _ref); (0 <= _ref ? section += 1 : section -= 1)) {
            _results.push(renderSection(section));
          }
          return _results;
        }).call(this);
        return this.$(this.element).empty().append(sections);
      };
      return TableView;
    })();
    Jb.SimpleCellView = (function() {
      function SimpleCellView() {
        SimpleCellView.__super__.constructor.apply(this, arguments);
      }
      __extends(SimpleCellView, View);
      SimpleCellView.prototype.template = Handlebars.compile('{{#if anchor}}\n  <a href="{{anchor}}">{{label}}</a> \n{{else}}\n  {{label}}\n{{/if}}');
      SimpleCellView.prototype.label = null;
      SimpleCellView.prototype.anchor = null;
      SimpleCellView.prototype.initialize = function() {
        return this.element = document.createElement('li');
      };
      SimpleCellView.prototype.setSelected = function(state) {
        if (state) {
          return this.$('a').addClass('selected');
        } else {
          return this.$('a').removeClass('selected');
        }
      };
      SimpleCellView.prototype.render = function() {
        var content;
        content = this.template({
          label: this.label,
          anchor: this.anchor
        });
        return this.element.innerHTML = content;
      };
      return SimpleCellView;
    })();
    return Jb;
  })();
}).call(this);

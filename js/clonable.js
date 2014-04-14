/*
 * Javascript 版 Clonable View
 *
 * Options:
 *   allowBlank [Boolean]: 是否允许为空
 *   maxNumber [Integer]: 数量限制
 *   preAdd [Function]: 添加前回调
 *   postAdded [Function]: 添加后回调
 *   preRemove [Function]: 删除前回调
 *   postRemoved [Function]: 删除后回调
 */

function ClonableView() {
  this.cid = _.uniqueId('view');
  this.delegateEventSplitter = /^(\S+)\s*(.*)$/;
  this.initialize.apply(this, arguments);
  this.delegateEvents();
}

ClonableView.prototype.$template = $('<div class="control-group"> \
  <div class="html-container"> \
  </div> \
  <div class="extra-buttons"> \
    <button type="button" class="btn btn-primary"> \
      <i class="icon-plus icon-white"></i> \
    </button> \
    <button type="button" class="btn btn-danger"> \
      <i class="icon-minus icon-white"></i> \
    </button> \
  </div> \
</div>');

ClonableView.prototype.className = 'clonable';
ClonableView.prototype.htmlContainer = '.html-container';
ClonableView.prototype.extraButtons = '.extra-buttons';

ClonableView.prototype.events = {
  'click .extra-buttons .btn-primary': 'add',
  'click .extra-buttons .btn-danger': 'remove'
};

ClonableView.prototype.initialize = function(options) {
  this.$el = $('<div>').addClass(this.className);

  if (options == null) {
    options = {};
  }
  this.$html = options['$html'];
  if (options['allowBlank'] == null) {
    options['allowBlank'] = false;
  }
  if (options['maxNumber'] != null) {
    options['maxNumber'] = parseInt(options['maxNumber']);
  }
  this.options = options;
};

ClonableView.prototype.render = function() {
  $item = this.$template.clone().appendTo(this.$el);
  if (!this.options['allowBlank']) {
    this.applyEvent('preAdd');
    this.$html.clone().appendTo($item.find(this.htmlContainer));
    this.delegateEvents();
    this.applyEvent('postAdded');
  }
  this.redrawExtraButtons();
  return this;
};

ClonableView.prototype.redrawExtraButtons = function(evt) {
  var childrenLength, conditionAvailabel;
  childrenLength = this.$el.children().length;
  conditionAvailabel = false;
  if (childrenLength === 1) {
    this.$el.find('.extra-buttons .btn-danger').prop('disabled', true);
    conditionAvailabel = true;
  }
  if (childrenLength == 1 && this.options.allowBlank) {
    this.$el.find('.extra-buttons .btn-primary').prop('disabled', false);
    conditionAvailabel = true;
  }
  if (this.options.allowBlank && this.$el.find(this.htmlContainer).children().length !== 0) {
    this.$el.find('.extra-buttons .btn-danger').prop('disabled', false);
    conditionAvailabel = true;
  }
  if (this.options.maxNumber && childrenLength === this.options.maxNumber) {
    this.$el.find('.extra-buttons .btn-primary').prop('disabled', true);
    conditionAvailabel = true;
  }
  if (conditionAvailabel) {
    return;
  }
  this.$el.find('.extra-buttons .btn-primary').prop('disabled', false);
  this.$el.find('.extra-buttons .btn-danger').prop('disabled', false);
  return this;
};

ClonableView.prototype.add = function(evt) {
  var $container, $el, rendered, $html;
  if (evt == null) {
    evt = {};
  }
  if (evt.target) {
    $el = $(evt.target);
  } else {
    $el = this.$el.find('.extra-buttons:last .btn-primary');
  }
  if ($el.parents('.control-group').find(this.htmlContainer).children().length === 0) {
    $container = $el.parents('.control-group');
  } else {
    $container = this.$template.clone().insertAfter($el.parents('.control-group')[0]);
  }
  this.undelegateEvents();
  this.applyEvent('preAdd');
  $html = this.$html.clone().appendTo($container.find(this.htmlContainer));
  this.redrawExtraButtons();
  this.delegateEvents();
  this.applyEvent('postAdded');
  return $html;
};

ClonableView.prototype.remove = function(evt) {
  var $el, el;
  this.applyEvent('preRemove');
  if (evt.target) {
    $el = $(evt.target);
  } else {
    $el = this.$el.find('.extra-buttons:last .btn-danger');
  }
  this.undelegateEvents();
  if (this.options.allowBlank && this.$el.children().length === 1) {
    el = $el.parents('.control-group').find(this.htmlContainer).children();
  } else {
    el = $el.parents('.control-group')[0];
  }
  $(el).remove();
  this.redrawExtraButtons();
  this.applyEvent('postRemoved');
  return this.delegateEvents();
};

ClonableView.prototype.clear = function() {
  return this.$el.find('.control-group').find(this.htmlContainer).empty();
};

ClonableView.prototype.setOptions = function(options) {
  this.options = _.extend(this.options, options);
  return this.redrawExtraButtons();
};

ClonableView.prototype.applyEvent = function(evtName) {
  if (this.options.hasOwnProperty(evtName)) {
    this.options[evtName].apply()
  }
}

/*
 * Porting from Backbone
 */

ClonableView.prototype.delegateEvents = function(events) {
  if (!(events || (events = _.result(this, 'events')))) return this;
  this.undelegateEvents();
  for (var key in events) {
    var method = events[key];
    if (!_.isFunction(method)) method = this[events[key]];
    if (!method) continue;

    var match = key.match(this.delegateEventSplitter);
    var eventName = match[1], selector = match[2];
    method = _.bind(method, this);
    eventName += '.delegateEvents' + this.cid;
    if (selector === '') {
      this.$el.on(eventName, method);
    } else {
      this.$el.on(eventName, selector, method);
    }
  }
  return this;
}

ClonableView.prototype.undelegateEvents = function() {
  this.$el.off('.delegateEvents' + this.cid);
  return this;
}

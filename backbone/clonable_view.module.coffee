module.exports = class ClonableView extends Backbone.View

  template: JST["clonable"]
  className: 'clonable'
  subviewContainer: '.subview-container'
  extraButtons: '.extra-buttons'
  
  events:
    'click .extra-buttons .btn-primary': 'add'
    'click .extra-buttons .btn-danger': 'remove'
  
  initialize: (options = {}) =>
    # TODO:
    #   1. allowBlank option, boolean type, if true will able to remove all of
    #      subviews [DONE]
    #   2. dragable option, boolean type, allow subview reoganize order.
    
    @subviewClass = options['subviewClass']
    if not options['subviewOptions']?
      options['subviewOptions'] = {}
    if not options['allowBlank']?
      options['allowBlank'] = false
    if options['limit']?
      options['limit'] = parseInt options['limit']
    @options = options

  render: =>
    @$el.html(@template())
    
    # Initial the first subview
    if not @options['allowBlank']
      @add()
    @redrawExtraButtons()
    @
  
  redrawExtraButtons: (evt) =>
    childrenLength = @$el.children().length
    conditionAvailabel = false
    if childrenLength == 1
      @$('.extra-buttons .btn-danger').prop('disabled', true)
      conditionAvailabel = true
    if childrenLength == 1 and @options.allowBlank
      @$('.extra-buttons .btn-primary').prop('disabled', false);
      conditionAvailabel = true
    if @options.allowBlank and @$el.find(@subviewContainer).children().length != 0
      @$('.extra-buttons .btn-danger').prop('disabled', false)
      conditionAvailabel = true
    if @options.limit and childrenLength == @options.limit
      @$('.extra-buttons .btn-primary').prop('disabled', true)
      conditionAvailabel = true
    if conditionAvailabel
      return
    @$('.extra-buttons .btn-primary').prop('disabled', false)
    @$('.extra-buttons .btn-danger').prop('disabled', false)
  
  add: (evt = {}) =>
    if evt.target
      $el = $(evt.target)
    else
      $el = @$('.extra-buttons:last .btn-primary') # 假设最后一个添加按钮
    if $el.parents('.control-group').find(@subviewContainer).children().length == 0
      $container = $el.parents('.control-group')
    else
      $container = $(@template()).insertAfter $el.parents('.control-group')[0]

    @undelegateEvents()
    subview = new @subviewClass @options.subviewOptions
    rendered = subview.render()
    @trigger('subviewPreAdd', subview)
    rendered.$el.appendTo($container.find(@subviewContainer))
    @redrawExtraButtons()
    @delegateEvents()
    @trigger('subviewPostAdded', subview)
    subview
  
  remove: (evt) =>
    @trigger('subviewPreRemoved')
    if evt.target
      $el = $(evt.target)
    else
      $el = @$('.extra-buttons:last .btn-danger') # 假设最后一个删除按钮
    @undelegateEvents()
    if @options.allowBlank and @$el.children().length == 1
      el = $el.parents('.control-group').find(@subviewContainer).children()
    else
      el = $el.parents('.control-group')[0]
      
    $(el).remove()
    @redrawExtraButtons()
    @trigger('subviewPostRemoved')
    @delegateEvents()

  clear: =>
    @$('.control-group').find(@subviewContainer).empty()

  setOptions: (options) =>
    @options = _.extend(@options, options)
    @redrawExtraButtons()

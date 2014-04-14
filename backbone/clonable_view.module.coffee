module.exports = class ClonableView extends Backbone.View

  template: JST["./clonable"]
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
    if options['maxNumber']?
      options['maxNumber'] = parseInt options['maxNumber']
    if not options['minNumber']?
      options['minNumber'] = 1
    else
      options['minNumber'] = parseInt options['minNumber']
    if not options['initialNumber']?
      options['initialNumber'] = 1
    @options = options

  render: =>
    @$el.html(@template())
    index = 0
    if @options['minNumber'] > @options['initialNumber']
      number = @options['minNumber']
    else
      number = @options['initialNumber']
    # Initial the first subview
    if not @options['allowBlank']
      while index < number
        @add()
        index += 1
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
    if @options['allowBlank'] and @$el.find(@subviewContainer).children().length != 0
      @$('.extra-buttons .btn-danger').prop('disabled', false)
      conditionAvailabel = true
    if @options['maxNumber'] and childrenLength == @options.maxNumber
      @$('.extra-buttons .btn-primary').prop('disabled', true)
      conditionAvailabel = true
    if childrenLength == @options['minNumber']
      @$('.extra-buttons .btn-danger').prop('disabled', true)
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
      # Assume the latest delete button
      $el = @$('.extra-buttons:last .btn-danger')
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
    # Limit to only one child.
    child = @$('.control-group:first').clone()
    @$el.html(child)
    # Empty the child.
    @$('.control-group').find(@subviewContainer).empty()

  setOptions: (options) =>
    @options = _.extend(@options, options)
    @redrawExtraButtons()

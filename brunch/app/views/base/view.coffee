Chaplin = require 'chaplin'
i18n = require 'lib/i18n'
require 'lib/view-helper' # Just load the view helpers, no return value

module.exports = class View extends Chaplin.View
  # Precompiled templates function initializer.

  getTemplateFunction: ->
    # Template compilation
    # --------------------

    # This demo uses Handlebars templates to render views.
    # The template is loaded with Require.JS and stored as string on
    # the view prototype. On rendering, it is compiled on the
    # client-side. The compiled template function replaces the string
    # on the view prototype.
    #
    # In the end you might want to precompile the templates to JavaScript
    # functions on the server-side and just load the JavaScript code.
    # Several precompilers create a global JST hash which stores the
    # template functions. You can get the function by the template name:
    #
    # templateFunc = JST[@templateName]

    # Register Handlebars Helper to use i18n in Templates
    Handlebars.registerHelper 'niceNumber', (number, options) =>
      @niceNumber number

    Handlebars.registerHelper 'firstName', (username, options) =>
      require('models/outgame/user-model').getFirstName(username)

    template = @template

    if typeof template is 'string'
      # Compile the template string to a function and save it
      # on the prototype. This is a workaround since an instance
      # shouldn’t change its prototype normally.
      templateFunc = Handlebars.compile template
      @constructor::template = templateFunc
    else
      templateFunc = template

    templateFunc

  initialize: ->
    super
    if @iphone5Class
      $('#iphone5bg').removeClass()
      $('#iphone5bg').addClass("#{@iphone5Class}")

  autoSizeText: (domElement = '.resize') ->
    elements = $(domElement)
    return if elements.length < 0

    for el in elements
      do (el) ->
        resizeText = ->
          elNewFontSize = (parseInt($(el).css('font-size'), 10) - 1)
          $(el).css('font-size', elNewFontSize)
        resizeText() while el.scrollHeight > el.offsetHeight or el.scrollWidth > el.offsetWidth

  displayMessage: (textKey, params) =>
    $('#question', @el).text i18n.t("view.game.#{@options.stage.i18n_key}.#{textKey}", params)

  dim: (callback) ->
    $('.fade-screen').addClass('animated fadeIn').one 'webkitAnimationEnd', ->
      $('.fade-screen').removeClass('animated fadeIn')
      callback?()

  unDim: (callback) ->
    page = document.getElementById('page-container')
    page.style.webkitTransform = page.style.webkitTransform
    $('.fade-screen').addClass('animated fadeOut').one 'webkitAnimationEnd', ->
      $('.fade-screen').removeClass('animated fadeOut')
      callback?()

  niceNumber: (value) ->
    value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ' ')

  delegateOnce: (eventName, second, third) ->
    if typeof eventName isnt 'string'
      throw new TypeError 'View#delegate: first argument must be a string'

    if arguments.length is 2
      handler = second
    else if arguments.length is 3
      selector = second
      if typeof selector isnt 'string'
        throw new TypeError 'View#delegate: ' +
          'second argument must be a string'
      handler = third
    else
      throw new TypeError 'View#delegate: ' +
        'only two or three arguments are allowed'

    if typeof handler isnt 'function'
      throw new TypeError 'View#delegate: ' +
        'handler argument must be function'

    # Add an event namespace, bind handler it to view.
    list = _.map eventName.split(' '), (event) => "#{event}.delegate#{@cid}"
    events = list.join(' ')
    bound = _.bind handler, this
    $((selector or null), @$el).one events, bound

    # Return the bound handler.
    bound

  undelegateSingle: (eventName, selector) ->
    $(selector, @$el).off(eventName)

  delegateSingleOnce: (eventName, second, third) ->
    if typeof eventName isnt 'string'
      throw new TypeError 'View#delegate: first argument must be a string'

    if arguments.length is 2
      handler = second
    else if arguments.length is 3
      selector = second
      if typeof selector isnt 'string'
        throw new TypeError 'View#delegate: ' +
          'second argument must be a string'
      handler = third
    else
      throw new TypeError 'View#delegate: ' +
        'only two or three arguments are allowed'

    if typeof handler isnt 'function'
      throw new TypeError 'View#delegate: ' +
        'handler argument must be function'

    singleHandler = (event) =>
      @undelegateSingle eventName, selector
      handler?(event)
    @delegateOnce eventName, selector, singleHandler
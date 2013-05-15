Chaplin = require 'chaplin'

# Layout is the top-level application ‘view’.
module.exports = class Layout extends Chaplin.Layout
  lastViewEl: null
  newViewEl: null
  lastIphone5Class: null

  initialize: ->
    super

    # Unsubscribe the originals events
    @unsubscribeEvent 'beforeControllerDispose', @hideOldView
    @unsubscribeEvent 'startupController', @showNewView

    # Resubscribe and do our shit
    @subscribeEvent 'startupController', @realShowNewView
    @subscribeEvent 'oldViewRegister', (view) =>
      @lastIphone5Class = view.iphone5
      @lastViewEl = view.el
      @lastViewEl.css {
        'z-index': '1',
        'position': 'relative',
        'margin': '0 auto'
      }

  # First we load the new view,
  # but we don't show it and then dimLayout
  # ---------------------------------------
  realShowNewView: (context) =>
    SpinnerHelper.startPartial()
    assetKey = context.controller.assetKey
    view = context.controller.view
    @newViewEl = view.$el if view
    @newViewEl.css('z-index', '0') if view
    if assetKey
      PreloadHelper.preloadAssets assetKey, =>
        @dimLayout @realHideOldView
    else
      @dimLayout @realHideOldView

  # Okey the new view is loaded,
  # we remove the old view then we unDim the layout
  # -----------------------------------------------
  realHideOldView: =>
    # If on iPhone5 we remove the big background
    $('#iphone5bg')?.removeClass("#{@lastIphone5Class}")

    # Don't want a spinner the view is loaded
    SpinnerHelper.stop()

    # Callback after oldViewRemoved
    callback = =>
      _.defer =>
        @unDimLayout(=> _.defer => @publishEvent('oldViewHided'))

    # If first launch, we can't wait for a DOMNodeRemoved
    if $('#page-container').children().length is 2
      $('#page-container').one('DOMNodeRemoved', callback)
      @lastViewEl?.remove()
    else
      @lastViewEl?.remove()
      callback()

  # Dim the layout
  # Use plugin on iOS
  # -----------------
  dimLayout: (callback, time = 0.300) =>
    if TransitionScreen?
      TransitionScreen.dim time, =>
        callback?()
    else
      $('#fade-screen').one('webkitAnimationEnd', =>
        _.defer =>
          $('#fade-screen').removeClass('fadeIn')
          callback?()
      ).addClass('animated fadeIn')

    # Redraw
    page = document.getElementById('page-container')
    page.style.webkitTransform = page.style.webkitTransform

  # unDim the layout
  # Use plugin on iOS
  # -----------------
  unDimLayout: (callback, time = 0.300) =>
    if TransitionScreen?
      TransitionScreen.unDim time, =>
        callback?()
    else
      $('#fade-screen').one('webkitAnimationEnd', =>
        _.defer =>
          $('#fade-screen').removeClass('animated fadeOut')
          callback?()
      ).addClass('fadeOut')

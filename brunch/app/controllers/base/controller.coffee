Chaplin       = require 'chaplin'
SoundHelper   = require 'helpers/sound-helper'
# Backbone    = require 'backbone'
PreloadHelper = require 'helpers/preload-helper'
mediator      = require 'mediator'

module.exports = class Controller extends Chaplin.Controller
  assetKey  : null
  historyURL: null

  # preloads assets for the view, if needed, and creates the view object
  # assetKey   : string   : key form assets_list.js / build_asset_list.rb containing asset paths associated for the view, defaults to controller's route
  # createView : function : returns the view instance (create and customize your view here) when assets are loaded
  # callback   : function : called when everything is ready with the created view instance as its argument
  # options.spinner    : bool     : spinner or not
  # options.tracked    : bool     : analytics or not analytics (page identifier is the title attributes from the controller)
  loadView: (@assetKey, createView, callback, options = {}) =>
    options.tracked ?= yes
    options.spinner ?= yes
    options.viewTransition ?= no
    options.music ?= no
    @assetKey ?= @historyURL
    loaded = =>
      @view = createView()
      callback @view if callback?
      mediator.analytics.trackPageView @title if options.tracked
      SoundHelper.play options.music if options.music
      @view.unDim() if options.viewTransition
    if @assetKey
      setTimeout =>
        PreloadHelper.preloadAssets @assetKey, loaded
      , 0
    else
      loaded()

  dispose: ->
    mediator.publish 'apicalls:abort'
    # unload all preloaded assets for the active view if needed
    if @assetKey
      PreloadHelper.removeAssets @assetKey
    super

  onClickALink: (e, name, links = {}) =>
    link = $(e.currentTarget).attr('href')
    if links[link]?
      mediator.analytics.trackEvent name, 'Click', links[link]
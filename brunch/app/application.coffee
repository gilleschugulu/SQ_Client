Chaplin       = require 'chaplin'
Layout        = require 'views/layout'
mediator      = require 'mediator'
routes        = require 'routes'
config        = require 'config/environment-config'

# The application object
module.exports = class Application extends Chaplin.Application
  # Set your application name here so the document title is set to
  # “Controller title – Site title” (see Layout#adjustTitle)
  title: config.app_name

  initialize: ->
    super
    # Initialize core components
    @initDispatcher controllerSuffix: '-controller'
    @initLayout()

    # Application-specific scaffold
    window.app = {}
    @initHelpers()
    @initMediator()
    @initControllers()
    @onDeviceReady()

    # Register all routes and start routing
    @initRouter routes, pushState: false
    # You might pass Router/History options as the second parameter.
    # Chaplin enables pushState per default and Backbone uses / as
    # the root per default. You might change that in the options
    # if necessary:
    # @initRouter routes, pushState: false, root: '/subdir/'
    unless config.log
      console.log = ->

    # Freeze the application instance to prevent further changes
    Object.freeze? this

  onDeviceReady: ->
    console.log "on device ready"
    @initCordovaPlugins()
    mediator.analytics.init()

  # Override standard layout initializer
  # ------------------------------------
  initLayout: ->
    # Use an application-specific Layout class. Currently this adds
    # no features to the standard Chaplin Layout, it’s an empty placeholder.
    @layout = new Layout {@title}

  # Instantiate common controllers
  # ------------------------------
  initControllers: ->
    # These controllers are active during the whole application runtime.
    # You don’t need to instantiate all controllers here, only special
    # controllers which do not to respond to routes. They may govern models
    # and views which are needed the whole time, for example header, footer
    # or navigation views.
    # e.g. new NavigationController()
    # new LoginController()

  initHelpers: ->
    SoundHelper = require 'helpers/sound-helper'
    SoundHelper.initialize()
    i18n = require 'lib/i18n'
    i18n.init()

  # Create additional mediator properties
  # -------------------------------------
  initMediator: ->
    # Add additional application-specific properties and methods

    # Create a user property
    # response =
        # player:
          # uuid: 'e999f160-42dc-0130-e782-38ac6f13ffa4'
          # credits: 50
          # email: "pierre@chugulu.com"
          # gender: "male"
          # nickname: "pierre"
          # notifications:
            # decrease_rank: false
            # info: false
            # ranking: false

    # mediator.user = new (require('models/outgame/user-model'))(response.player)
    mediator.analytics = require 'helpers/analytics-helper'
    mediator.justLaunched = yes
    mediator.user = {}

    mediator.setJustLaunched = (value) ->
      mediator.justLaunched = value

    mediator.setUser = (User) ->
      mediator.user = User

    # Seal the mediator
    mediator.seal()

  initCordovaPlugins: ->
    Social?.updateAvailableServices()
    Message?.checkCanSendMail()
    Message?.checkCanSendText()
    AdColony?.init config.services.adcolony.zones
    TapjoyConnect?.requestTapjoyConnect null, null, ->
      TapjoyConnect.initVideoAd()
    GameCenter?.authenticateLocalUser()
    ChartBoost?.cacheInterstitial()


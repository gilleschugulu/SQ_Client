Controller          = require 'controllers/base/controller'
utils               = require 'lib/utils'
LocalStorageHelper  = require 'helpers/local-storage-helper'
LoginView           = require 'views/outgame/login-view'
mediator            = require 'mediator'
PopUpHelper         = require 'helpers/pop-up-helper'
FacebookHelper      = require 'helpers/facebook-helper'
ApiCallHelper       = require 'helpers/api-call-helper'
User                = require 'models/outgame/user-model'
i18n                = require 'lib/i18n'
AnalyticsHelper     = require 'helpers/analytics-helper'
config              = require 'config/environment-config'

module.exports = class LoginController extends Controller
  historyURL: ''
  params = {}

  # Login the player if exists or show login view
  # ---------------------------------------------
  index: =>
    if Parse.User.current()
      @bindPlayer()
    else
      @showLoginView()

    # Suscribe to Events
    @subscribeEvent 'login:gotPlayer', @bindPlayer

  # Show the login view
  # -------------------
  showLoginView: =>
    @loadView 'login', ->
      new LoginView()
    , (view) =>
      view.animateFacebook()
      navigator.splashscreen.hide() if navigator?.splashscreen?.hide?
      view.delegate "click", "#facebook-login", =>
        AnalyticsHelper.trackEvent 'Login', 'Login with facebook'

        # Note : logIn automatically creates a Parse.User in case of success \o/
        Parse.FacebookUtils.logIn('email, user_location, user_birthday, publish_stream', 
          success: =>
            console.log 'Player will be logged in thanks to Facebook'
            @bindPlayer()
          , error: (response) =>
            if config.services.facebook.createAnyway
              console.log 'Forced creation of player even if Facebook fail (local)'
              # We don't have a nickname to use (must be uniq), so we must generate one
              Parse.User.signUp(Math.random() * 56056105 + '', 'password', (new User).attributes, 
                success: =>
                  user = Parse.User.current()
                  console.log(user, user?.get('username'))
                  @bindPlayer()
              )
            else
              PopUpHelper.initialize {message: 'Erreur avec Facebook', title: 400, key: 'api-error'}
        )

        # FacebookHelper.getLoginStatus()
    , {viewTransition: yes}


  # Save player in the mediator and uuid in localStorage
  # ----------------------------------------------------
  bindPlayer: =>
    Parse.User.current().fetch
      success: (user, user_attributes) =>
        console.log 'BindPlayer with user', user.get('username')

        # Save user to mediator
        mediator.setUser user

        # Save or update uuid in LocalStorage
        @initPushNotifications()
        @redirectHome()


  # Good, we got our user we just redirect to home
  # ----------------------------------------------
  redirectHome: =>
    @redirectTo 'home'

  # TODO : Adapth this with Parse (get token and call an api to store it)
  initPushNotifications: ->
    if PushNotifications?
      PushNotifications.configure
        buttonCancel: i18n.t('helper.push.how_about_no')
        buttonOK    : i18n.t('helper.push.kthx')
      # PushNotifications.register (pushData) ->
      #   console.log "GOT TOKEN"
      #   pushData.uuid = mediator.user.get('uuid')
      #   console.log pushData
      #   ApiCallHelper.send.registerPushToken pushData

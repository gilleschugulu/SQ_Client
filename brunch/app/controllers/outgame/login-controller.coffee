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
LequipeSSOHelper    = require 'helpers/lequipe-sso-helper'

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

  loginToParse: (user, params) =>
    manageError = (child, error, opts) ->
      # manage parse error here
      # at this point user exists in SSO, so we can show "try again[ later]"
      console.log "PARSE ERROR"
      console.log error
    Parse.User.logIn params.username, params.password, {
      success: =>
        console.log "PARSE LOGIN SUCCESS", arguments
        @bindPlayer()
      error: (child, error, opts) =>
        console.log "PARSE LOGIN ERROR", arguments
        # signUp if user does not exists
        if error.code is Parse.Error.OBJECT_NOT_FOUND
          delete user.id
          u = new User user
          console.log "USER", u
          options =
            success: =>
              console.log "SUCCESS SIGN UP", arguments
              @bindPlayer()
            error: =>
              console.log "ERROR SIGN UP", arguments
              manageError.apply null, arguments
          Parse.User.signUp params.username, params.password, u.attributes, options
        else
          manageError.apply null, arguments
    }

  loginWithSSO: =>
    console.log "LOGIN YO"
    form = $('#sso-login-form', @view.$el).serializeArray()
    params = {}
    params[f.name] = f.value for f in form
    console.log params
    LequipeSSOHelper.login params, (user) =>
      console.log "GOT USER", user
      @loginToParse user, params
    , (status, error) ->
      console.log "LOGIN ERROR", status, error
    no

  registerWithSSO: =>
    console.log "REGISTER YO"
    form = $('#sso-register-form', @view.$el).serializeArray()
    params = {}
    params[f.name] = f.value for f in form
    console.log params
    LequipeSSOHelper.register params, (user) =>
      console.log "GOT USER", user
      @loginToParse user, params
    , (status, error) ->
      console.log "LOGIN ERROR", status, error
    no

  # Show the login view
  # -------------------
  showLoginView: =>
    @loadView 'login', ->
      new LoginView()
    , (view) =>
      view.animateFacebook()
      navigator.splashscreen.hide() if navigator?.splashscreen?.hide?
      view.delegate 'click', '#register-btn', @registerWithSSO
      view.delegate 'click', '#login-btn', @loginWithSSO
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

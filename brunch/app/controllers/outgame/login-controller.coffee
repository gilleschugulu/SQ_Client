Controller          = require 'controllers/base/controller'
utils               = require 'lib/utils'
LocalStorageHelper  = require 'helpers/local-storage-helper'
DeviceHelper        = require 'helpers/device-helper'
LoginView           = require 'views/outgame/login-view'
mediator            = require 'mediator'
PopUpHelper         = require 'helpers/pop-up-helper'
FacebookHelper      = require 'helpers/facebook-helper'
User                = require 'models/outgame/user-model'
i18n                = require 'lib/i18n'
AnalyticsHelper     = require 'helpers/analytics-helper'
config              = require 'config/environment-config'
SpinnerHelper       = require 'helpers/spinner-helper'
LequipeSSOHelper    = require 'helpers/lequipe-sso-helper'
ConfigHelper        = require 'helpers/config-helper'
_                   = require 'underscore'

module.exports = class LoginController extends Controller
  historyURL: ''
  title: 'Login'
  checkAvailabilityWithSSOTimeout : null
  params = {}

  # Login the player if exists or show login view
  # ---------------------------------------------
  index: =>
    if DeviceHelper.isConnected()
      PopUpHelper.disposePopup 'no-connection'
      if Parse.User.current()
        @bindPlayer()
      else
        @showLoginView()
      # Suscribe to Events
      @subscribeEvent 'login:gotPlayer', @bindPlayer
    else
      if PopUpHelper.numberOfPopup() is 0
        PopUpHelper.initialize {message: i18n.t('helper.apiCall.error.connection'), title: i18n.t('helper.apiCall.error.title'), key: 'no-connection', info: no, confirmation: no}
        @showLoginView()
      setTimeout @index, 3000

  loginToParse: (user, params) =>
    manageError = (child, error, opts) ->
      # manage parse error here
      # at this point user exists in SSO, so we can show "try again[ later]"
      console.log "PARSE ERROR"
      console.log error
    Parse.User.logIn params.username, params.password, {
      success: =>
        @bindPlayer()
      error: (child, error, opts) =>
        # signUp if user does not exists
        if error.code is Parse.Error.OBJECT_NOT_FOUND
          delete user.id
          u = new User user
          options =
            success: =>
              @bindPlayer()
            error: =>
              manageError.apply null, arguments
          Parse.User.signUp params.username, params.password, u.attributes, options
        else
          manageError.apply null, arguments
    }

  loginWithFacebook: =>
    AnalyticsHelper.trackEvent 'Login', 'Login with facebook'

    success = (user_attributes) =>
      if user_attributes.bonus
        @bindPlayer(parse_attributes)
      else
        FacebookHelper.getPersonalInfo (fb_attributes) =>
          parse_attributes = User.prototype.defaults
          parse_attributes.username = fb_attributes.name
          parse_attributes.fb_id = fb_attributes.id

          @bindPlayer(parse_attributes)

    error = (response) =>
      SpinnerHelper.stop()
      PopUpHelper.initialize {message: 'Erreur avec Facebook', title: 400, key: 'api-error'}

    FacebookHelper.logIn success, error

  loginWithSSO: =>
    unless @validateForm('#sso-login-form')
      return no
    AnalyticsHelper.trackEvent 'Login', 'Login with SSO', 'Submit'
    form = $('#sso-login-form', @view.$el).serializeArray()
    params = {}
    params[f.name] = f.value for f in form
    LequipeSSOHelper.login params, (user) =>
      @loginToParse user, params
    , (status, error) =>
      console.log "LOGIN ERROR", status, error
      AnalyticsHelper.trackEvent 'Login', 'Login with SSO', 'Error ' + status + ' ' + error.description
      msg = 'unknown'
      switch status
        when LequipeSSOHelper.error.login.INCORRECT_MAIL
          $("#sso-login-form input[name=username]", @view.$el).addClass 'invalid'
          msg = 'incorrect_mail'
        when LequipeSSOHelper.error.login.INCORRECT_PASSWORD
          $("#sso-login-form input[name=password]", @view.$el).addClass 'invalid'
          msg = 'incorrect_password'
        when LequipeSSOHelper.error.login.INVALID_PARAMETERS
          msg = 'invalid_login_params'
      PopUpHelper.initialize
        title  : i18n.t 'controller.login.sso_equipe.error_title'
        message: i18n.t "controller.login.sso_equipe.#{msg}"
        key    : 'sso_equipe_invalid'
    no

  registerWithSSO: =>
    unless @validateForm('#sso-register-form')
      return no
    AnalyticsHelper.trackEvent 'Login', 'Register with SSO', 'Submit'
    form = $('#sso-register-form', @view.$el).serializeArray()
    params = {}
    params[f.name] = f.value for f in form
    LequipeSSOHelper.register params, (user) =>
      @loginToParse user, params
    , (status, error) =>
      console.log "REGISTER ERROR", status, error
      AnalyticsHelper.trackEvent 'Login', 'Register with SSO', 'Error ' + status + ' ' + error.description
      msg = 'unknown'
      switch status
        when LequipeSSOHelper.error.register.NOT_AVAILABLE
          msg = 'already_used'
          $("#sso-register-form input[name=email]", @view.$el).addClass 'invalid'
          $("#sso-register-form input[name=username]", @view.$el).addClass 'invalid'
        when LequipeSSOHelper.error.register.INVALID_PARAMETERS
          msg = 'invalid_register_params'
      PopUpHelper.initialize
        title  : i18n.t 'controller.login.sso_equipe.error_title'
        message: i18n.t "controller.login.sso_equipe.#{msg}"
        key    : 'sso_equipe_invalid'
    no

  # check to see if email/username are available
  checkAvailabilityWithSSO: =>
    form = $('#sso-register-form', @view.$el).serializeArray()
    params = {}
    params[f.name] = f.value for f in form
    LequipeSSOHelper.alreadyUsed params, (user) =>
      # alert('email/username sont pas dispo')
      $("#sso-register-form input[name=email]", @view.$el).addClass 'invalid'
      $("#sso-register-form input[name=username]", @view.$el).addClass 'invalid'
      PopUpHelper.initialize
        title  : i18n.t 'controller.login.sso_equipe.error_title'
        message: i18n.t 'controller.login.sso_equipe.invalid'
        key    : 'sso_equipe_invalid'
    , (code, error) =>
      if code is LequipeSSOHelper.error.alreadyUsed.USED_BY_ANOTHER_USER
        # alert('email/username sont pas dispo')
        $("#sso-register-form input[name=email]", @view.$el).addClass 'invalid'
        $("#sso-register-form input[name=username]", @view.$el).addClass 'invalid'
        PopUpHelper.initialize
          title  : i18n.t 'controller.login.sso_equipe.error_title'
          message: i18n.t 'controller.login.sso_equipe.already_used'
          key    : 'sso_equipe_invalid'

  validateForm: (formId) =>
    validationRules =
      email   : /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,4})+$/
      username: /^[a-zA-Z0-9_\-\.àáâãäçèéêëìíîïñòóõöûüúù@?£%€\(\)°\[\]\}\{\*~\\'"]{6,}$/
    form = $(formId, @view.$el).serializeArray()
    invalidFields = []
    for f in form
      if validationRules[f.name]?
        if not validationRules[f.name].test f.value
          invalidFields.push f.name
          $("#{formId} input[name=#{f.name}]", @view.$el).addClass 'invalid'
        else
          $("#{formId} input[name=#{f.name}]", @view.$el).removeClass 'invalid'
    console.log "INVALID", invalidFields
    if invalidFields.length > 0
      # console.error invalidFields.join(',') + ' pas bon'
      PopUpHelper.initialize
        title  : i18n.t 'controller.login.sso_equipe.error_title'
        message: (i18n.t("controller.login.sso_equipe.field_error_#{field}") for field in invalidFields)
        key    : 'sso_equipe_invalid'
      return no
    yes

  # Show the login view
  # -------------------
  showLoginView: =>
    @loadView 'login', ->
      new LoginView()
    , (view) =>
      view.animateFacebook()
      navigator.splashscreen.hide() if navigator?.splashscreen?.hide?
      view.delegate 'click', '#register-btn', @registerWithSSO
      view.delegate 'click', "#facebook-login", @loginWithFacebook
      view.delegate 'click', '#login-btn', @loginWithSSO
      view.delegate 'submit', '#sso-login-form', @loginWithSSO
      view.delegate 'submit', '#sso-register-form', @registerWithSSO

      check = (e) =>
        clearTimeout @checkAvailabilityWithSSOTimeout
        @checkAvailabilityWithSSOTimeout = setTimeout @checkAvailabilityWithSSO, 1000
      view.delegate 'keyup', '#sso-register-form input[name=email]', check
      view.delegate 'keyup', '#sso-register-form input[name=username]', check
      view.delegate 'click', '#close-btn', ->
        view.closeForms()
      view.delegate 'click', '#equipe-login', ->
        AnalyticsHelper.trackEvent 'Login', 'Login/Register with SSO', 'Click'
        view.openForms()

    , {viewTransition: yes}


  # Save player in the mediator and uuid in localStorage
  # ----------------------------------------------------
  bindPlayer: (parse_attributes) =>
    Parse.User.current().fetch
      success: (user, user_attributes) =>
        if parse_attributes
          attr = {}
          for k, v of user_attributes
            attr[k] = v
          for k, v of parse_attributes
            attr[k] = v

          user.set(attr).save()

        # Save user to mediator
        mediator.setUser user

        # Save or update uuid in LocalStorage
        @initPushNotifications()
        SpinnerHelper.stop()
        @redirectHome()


  # Good, we got our user we just redirect to home
  # ----------------------------------------------
  redirectHome: =>
    @redirectTo 'home'

  initPushNotifications: ->
    if PushNotifications?
      PushNotifications.configure
        buttonCancel: i18n.t('helper.push.how_about_no')
        buttonOK    : i18n.t('helper.push.kthx')
      PushNotifications.register (pushData) ->
        console.log 'Will register PushNotifications'
        data =
          deviceToken: pushData.token.replace(/\s+/g, '')
          deviceType : 'ios'
        $.ajax
            url        : 'https://api.parse.com/1/installations'
            dataType   : 'json'
            contentType: 'application/json'
            data       : JSON.stringify data
            type       : 'POST'
            success    : (response) ->
              console.log "PARSE SUCCESS"
              console.log response
            error      : ->
              console.log "PARSE ERROR"
              console.log arguments
            headers    : ConfigHelper.config.services.parse.headers
        # pushData.uuid = mediator.user.get('uuid')
        # ApiCallHelper.send.registerPushToken pushData

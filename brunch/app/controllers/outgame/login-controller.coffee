Controller         = require 'controllers/base/controller'
utils              = require 'lib/utils'
LocalStorageHelper = require 'helpers/local-storage-helper'
LoginView          = require 'views/outgame/login-view'
mediator           = require 'mediator'
PopUpHelper        = require 'helpers/pop-up-helper'
FacebookHelper     = require 'helpers/facebook-helper'
ApiCallHelper      = require 'helpers/api-call-helper'
User               = require 'models/outgame/user-model'
i18n               = require 'lib/i18n'
AnalyticsHelper    = require 'helpers/analytics-helper'

module.exports = class LoginController extends Controller
  historyURL: ''
  params = {}

  # Login the player if exists or show login view
  # ---------------------------------------------
  index: =>
    # return @redirectHome()
    # # If already registered login the user
    if LocalStorageHelper.exists 'uuid'
      # Call server to get the player
      ApiCallHelper.fetch.player LocalStorageHelper.get('uuid')
        , (response) =>
          # Success Callback
          @bindPlayer response.player
      # response =
      #   player:
      #     uuid: 'e999f160-42dc-0130-e782-38ac6f13ffa4'
      #     credits: 50
      #     email: "pierre@chugulu.com"
      #     gender: "male"
      #     nickname: "pierre"
      #     notifications:
      #       decrease_rank: false
      #       info: false
      #       ranking: false

      # @bindPlayer response.player

    # Else show the login View
    else
      @showLoginView()

    # Suscribe to Events
    @subscribeEvent 'login:gotPlayer', @bindPlayer
    @subscribeEvent 'popup:api-error:ok', @loginError

  # Show the login view
  # -------------------
  showLoginView: =>
    @loadView 'login', ->
      new LoginView()
    , (view) =>
      view.animateFacebook()
      navigator.splashscreen.hide() if navigator?.splashscreen?.hide?
      # Bind email connect
      view.delegate "click", "#email-login", =>
        # Track Event
        AnalyticsHelper.trackEvent 'Login', 'Show email login'
        # Show the correct View
        view.showMailLoginView()
        # Prevent default submit action
        $('#login').on 'submit', (event) -> event.preventDefault()
        # Bind only once the submit for no double click
        $("#login").one 'submit', => @postAccount()
      # Bind the facebook connect
      view.delegate "click", "#facebook-login", ->
        # Track Event
        AnalyticsHelper.trackEvent 'Login', 'Login with facebook'
        FacebookHelper.getLoginStatus()
    , {viewTransition: yes}

  # Call server to login or register user
  # -------------------------------------
  postAccount: (connect = null) =>
    # Close keyboardview if open
    $('#email, #code').blur()
    # Validate the form informations before sending
    if @validateForm()
      # Get params
      params.player = $('#login').serializeObject()
      # Call server
      if connect
        ApiCallHelper.fetch.playerWithCode params
          , (response) =>
            # Success Callback
            @bindPlayer response.player
            AnalyticsHelper.trackEvent 'Login', 'Login with email and code sucess'
      else
        ApiCallHelper.send.createPlayer params
          , (response) =>
            # Success Callback
            @bindPlayer response.player, true
            AnalyticsHelper.trackEvent 'Login', 'Create account with email sucess'
          ,  (apiResponse, response) =>
            # Error Callback
            error = apiResponse.error
            if error.action?
              @alreadyEmail() if error.action is 'already_email'
              @alreadyFacebook() if error.action is 'already_facebook'
            else
              PopUpHelper.initialize {message: error.messages, title: error.code, key: 'api-error'}
    else
      # Rebind the submit if form didn't validate
      $('#login').one 'submit', => @postAccount(true if connect)

  # The form validation before sending
  # ----------------------------------
  validateForm: ->
    email_val = $('#email').val()
    email_regex = new RegExp("^[-_.+a-zA-Z0-9]+@[-_a-zA-Z0-9]+\.[a-zA-Z]{2,4}$")
    # Check if email field isnt empty
    if email_val.length isnt 0
      # Check if email field value is an email
      if email_regex.test(email_val) and !$('#code').length
        return true
      # Check if there's a code input and if it's well filled
      else if $('#code').length and $('#code').val().length is 4 and email_regex.test(email_val)
        return true
      else
        return false
    else
      return false

  # Case if email is already used to show the code input
  # ----------------------------------------------------
  alreadyEmail: =>
    # Track event
    AnalyticsHelper.trackEvent 'Login', 'Email already registered'
    # Create a popup object to tell user email already registered
    popup_obj =
      message: i18n.t('view.outgame.login.already_email')
      title: "already email registered"
      key: "already-email"
    # Show the popup
    PopUpHelper.initialize popup_obj
    # Subscribe on click OK
    @subscribeEvent 'popup:already-email:ok', =>
      # Remove useless radio input
      $('#radio').remove() if $('#code').length is 0
      # Insert code input
      code_input = "<input name='code' type='number' pattern='[0-9]*' placeholder='code' id='code' value='' require maxlength='4'><br><br>"
      $('#submit').before code_input if $('#code').length is 0
      # Rebind submit of the form
      $('#login').one "submit", => @postAccount(true)

  # Case if email is already linked to a Facebook account
  # -----------------------------------------------------
  alreadyFacebook: =>
    # Track event
    AnalyticsHelper.trackEvent 'Login', 'Email already registered to facebook'
    # Popup to tell user what is happening
    popup_obj =
      message: i18n.t('view.outgame.login.already_email')
      title: "already email linked to facebook"
      key: "already-facebook"
    # Show the popup
    PopUpHelper.initialize popup_obj
    # Subscribe en click OK
    @subscribeEvent 'popup:already-facebook:ok', -> FacebookHelper.getLoginStatus()

  # Save player in the mediator and uuid in localStorage
  # ----------------------------------------------------
  bindPlayer: (user, created = no) =>
    # Save user to mediator
    mediator.setUser new User(user)

    # Save or update uuid in LocalStorage
    LocalStorageHelper.set 'uuid', mediator.user.get('uuid')
    @initPushNotifications()
    # If new Player show a popup of welcome
    if created
      PopUpHelper.initialize {message: 'welcome on app', title: 'welcome', key: 'welcome-message'}
      @subscribeEvent 'popup:welcome-message:ok', @redirectHome
    else
      @redirectHome()

  # If server answer with an error during creation/login
  # ----------------------------------------------------
  loginError: =>
    # unsubscribeEvents
    @unsubscribeAllEvents()
    # Delete uuid
    LocalStorageHelper.delete 'uuid'
    # dispose the view
    @view?.dispose()
    # Redirect to login and start again
    @showLoginView()

  # Good, we got our user we just redirect to home
  # ----------------------------------------------
  redirectHome: =>
    # Redirect to Home and we're done!
    @redirectTo 'home'

  initPushNotifications: ->
    if PushNotifications?
      PushNotifications.configure
        buttonCancel: i18n.t('helper.push.how_about_no')
        buttonOK    : i18n.t('helper.push.kthx')
      PushNotifications.register (pushData) ->
        console.log "GOT TOKEN"
        pushData.uuid = mediator.user.get('uuid')
        console.log pushData
        ApiCallHelper.send.registerPushToken pushData

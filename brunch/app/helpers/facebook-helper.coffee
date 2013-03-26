mediator      = require 'mediator'
utils         = require 'lib/utils'
PopUpHelper   = require 'helpers/pop-up-helper'
i18n          = require 'lib/i18n'
spinner       = require 'helpers/spinner-helper'

module.exports = class FacebookHelper
  self = @
  @params =
    url:
      provider:
        first_name: null
        last_name : null
        identifier: null
        token     : null
      player:
        email : null
        gender: null
    to_change:
        provider_name: 'facebook'

  # Get Login Status from Facebook
  # ------------------------------
  @getLoginStatus: (create = true, link = false, callback) ->
    # We start the spinner because we gonna ask facebook
    spinner.start()
    console.log "spinner start getLoginStatus"
    FB.getLoginStatus (response) ->
      # Stop spinner
      spinner.stop()
      console.log "spinner stop getLoginStatus"
      # The player already authorized the app
      if response.status is "connected"
        self.params.url.provider.token = response.authResponse.accessToken
        # Call API /me for getting infos
        self.apiMeCall create, link, callback
      else
        # Call login for authorize the app
        self.login create, link, callback

  # Ask user to autorize the app
  # ----------------------------
  @login: (create = false, link = false, callback) ->
    # Spinner start, request to facebook
    console.log "spinner start login"
    spinner.start()
    FB.login (response) ->
      console.log "spinner stop login"
      spinner.stop()
      if response.authResponse
        # got answer from facebook saving accesstoken and go ask API /me
        self.params.url.provider.token = response.authResponse.accessToken
        self.apiMeCall create, link, callback
      else
        console.log "user taped cancel"
    # What do we need from the user?
    , {scope: 'email, user_location, user_birthday, publish_stream'}

  # Call Facebook API to get UserInfos
  # ----------------------------------
  @apiMeCall: (create = false, link = false, callback) ->
    # Again spinner start
    console.log "spinner start apiMeCall"
    spinner.start()
    FB.api '/me', (response) ->
      spinner.stop()
      console.log "spinner stop apiMeCall"
      if !response or response.error
        # When user de-authorized the app from facebook, going to ask facebook again
        if response.error.code is 190
          self.login create, link
        else
          console.log 'we are fucked this is an error with facebook'
      else
        # Save informations in the params
        self.params.url.provider.identifier = response.id
        self.params.url.provider.first_name = response.first_name
        self.params.url.provider.last_name  = response.last_name
        self.params.url.player =
          email : response.email
          gender: response.gender

        # Create account
        if create and !link then self.registerPlayer callback
        # Link account
        if !create and link then self.linkPlayer callback
        # Connect to account
        if !create and !link then self.connectPlayer callback

  # Friends invite request
  # ----------------------
  @friendRequest: (message, callback = null) ->
    @getLoginStatus no, yes, (response) ->
      # if no message is no provided, return
      unless !!message
        return alert "FB.request: pas de message :("

      # if message is incorrect, return
      if message.length < 1 or message.length > 255
        return alert "FB.request: message doit faire entre 1 et 255 characteres (" + message.length + " actuellement)"

      # Checking FB is existant
      FB.ui {method: 'apprequests', message: message}, (response) =>
        # if we have a callback for this method, then use it (for exemple avoid rewarding?)
        if response and callback
          callback(response)

  # Register Player
  # ---------------
  @registerPlayer: (callback) ->
    # Calling server
    ApiCallHelper.send.createPlayerWithProvider self.params
      , (response) -> # Success Callback
        callback?(response)
        self.postUserFeed {
          description: i18n.t('helper.facebook.create_account_sucess.description')
          name: i18n.t('helper.facebook.create_account_sucess.name')
        }
        mediator.publish 'login:gotPlayer', response.player
      , (response) -> # Error Callback
        error = response.errors
        PopUpHelper.initialize {message: error.message, title: error.code, key: 'fb-create-error'}

  # Link player from profile page
  # -----------------------------
  @linkPlayer: (callback) ->
    # we dont need these params
    delete self.params.url.provider.first_name
    delete self.params.url.provider.last_name
    delete self.params.url.player
    self.params.to_change.uuid = mediator.user.get 'uuid'

    # Calling server
    ApiCallHelper.send.linkPlayerWithProvider self.params
      , (response) -> # Success Callback
        callback?(response)
        popup_obj =
          message: 'Provider linked successfully, you can logon with facebook now'
          title  : 'Great!'
          key    : 'link-facebook'
      , callback

  # Connect player to the app
  # -------------------------
  @connectPlayer: (callback) ->
    # we dont need these params
    delete self.params.url.provider.first_name
    delete self.params.url.provider.last_name
    delete self.params.url.player

    # Calling server
    ApiCallHelper.fetch.playerWithProvider self.paramss
      , (response) -> # Success Callback
        callback?(response)
        mediator.publish 'login:gotPlayer', response.player
      , (response) -> # Error Callback
        callback?(response)
        error = response.errors
        PopUpHelper.initialize {message: error.message, title: error.code, key: 'fb-login-error'}

  # Post on user feed
  # @params :
  #   - message
  #   - name
  #   - link
  #   - picture
  #   - caption
  #   - description
  # -----------------
  @postUserFeed: (params) ->
    params.picture = i18n.t('helper.game_icon') unless params.picture
    params.link = i18n.t('helper.app_store_link') unless params.link
    FB.api 'me/feed', 'post', params, (response) ->
      if !response or response.error
        console.log 'error occured', response
      else
        console.log 'success', response

  # Post score
  # ----------
  @postScore: (score) ->
    FB.api '/me/scores', 'post', {score: score}, (response) ->
      console.log 'Score was posted to facebook', {score}

  # # Like the appli
  # # HAHA, like an Open Graph object. Not usable now, maybe later
  # # -------------------------------------------------
  # @likeAppli: (callback) ->
  #   FB.api '/me/og.likes',
  #     'post',
  #       object: "http://samples.ogp.me/226075010839791"
  #     (response) ->
  #       callback?(response)

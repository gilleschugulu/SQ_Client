mediator      = require 'mediator'
utils         = require 'lib/utils'
PopUpHelper   = require 'helpers/pop-up-helper'
DeviceHelper  = require 'helpers/device-helper'
i18n          = require 'lib/i18n'
spinner       = require 'helpers/spinner-helper'

module.exports = class FacebookHelper
  self = @
  @defaultScope = ['email','user_location','user_birthday']
  @publishScope = ['publish_stream']

  @logIn: (success, error, scope = @defaultScope) ->
    s = (user) ->
      spinner.stop()
      user.set('fb_id', user.get('authData').facebook.id).save()
      success?.apply null, arguments
    e = ->
      spinner.stop()
      error?.apply null, arguments
    spinner.start()
    scope = scope.join ',' if _.isArray scope
    Parse.FacebookUtils.logIn scope,
      success: s
      , error: e

  # Friends invite request
  # ----------------------
  @friendRequest: (message, callback, errorCallback) ->
    doRequest = =>
      # if no message is no provided, return
      unless !!message
        return alert "FB.request: pas de message :("

      # if message is incorrect, return
      if message.length < 1 or message.length > 255
        return alert "FB.request: message doit faire entre 1 et 255 characteres (" + message.length + " actuellement)"

      # Checking FB is existant
      user = Parse.User.current()
      @getOtherFriends (friends) ->
        notInstalledFriends = _.pluck(friends, 'id')
        user_ids = _.difference(notInstalledFriends, user.get('fb_invited'))
        FB.ui {method: 'apprequests', message, filters: [{name : 'invite friends', user_ids}]}, (response) ->
          return unless response
          # On iOs, response.to doesn't exist, and we receive "to%5B0%5D" (to[0]). Weiiiird.
          if response.to 
            invited_players = response.to
          else if response['to%5B0%5D']
            invited_players = (v for k,v of response when /^to%5B[0-9]+%5D$/.test k)
          else return

          invited_players = _.difference invited_players, user.get('fb_invited')

          # If we have a callback for this method, then use it (for exemple avoid rewarding?)
          # Add a life at user per NEW friends added
          if invited_players.length > 0
            user.set("fb_invited", _.uniq(invited_players.concat(user.get('fb_invited')))).increment('health', invited_players.length).save()

          callback?(invited_players.length)
        , ->
          errorCallback?()

    unless @isLinked()
      @linkPlayer doRequest, errorCallback
    else
      FB.getLoginStatus (response) =>
        console.log "getLoginStatus"
        console.log response
        if response and response.status is 'connected'
          doRequest()
        else
          @logIn doRequest, errorCallback
      , errorCallback

  @friendRequestTo: (message, friend, callback) ->
    doRequest = ->
      # if no message is no provided, return
      unless !!message
        return alert "FB.request: pas de message :("

      # if message is incorrect, return
      if message.length < 1 or message.length > 255
        return alert "FB.request: message doit faire entre 1 et 255 characteres (" + message.length + " actuellement)"

      # Checking FB is existant
      user = Parse.User.current()
      FB.ui {method: 'apprequests', message, to: friend}, (response) =>
        # if we have a callback for this method, then use it (for exemple avoid rewarding?)
        console.log "request to"
        console.log response
        user.set("fb_invited", _.uniq(response.to.concat(user.get('fb_invited'))))
        user.increment("health", 1).save()
        if response and callback
          callback(response)
      , (error) ->
        console.log "DIALOG FAILED"
        console.log error

    console.log "REQUEST"
    unless @isLinked()
      console.log "REQUEST LINKING"
      @linkPlayer doRequest
    else
      console.log "REQUEST STATUS"
      FB.getLoginStatus (response) =>
        console.log "getLoginStatus"
        console.log response
        if response and response.status is 'connected'
          doRequest()
        else
          @logIn doRequest
      , (stuff) ->
        console.log "REQUEST STATUS FAILED"
        console.log stuff

  @isLinked: ->
    Parse.FacebookUtils.isLinked(Parse.User.current())

  # Link player from profile page
  # -----------------------------
  @linkPlayer: (successCallback, errorCallback) ->
    success = (user) ->
      fb_id = user.get('authData').facebook.id
      user.set('fb_id', fb_id).save()
      successCallback?(user)

    Parse.FacebookUtils.link Parse.User.current(), @defaultScope.join(','), {success, error:errorCallback}

  @unlinkPlayer : (error) ->
    Parse.FacebookUtils.unlink Parse.User.current(),
      success : (user) ->
        user.set('fb_id', null).save()
      error : error

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
    # TODO
    # if logged in or linked
    #   check has publish_actions permission
    #     yes => post
    #     no => login with @publishPermissions => post
    # else
    #   login with @publishPermissions => post
    FB.api '/me/scores', 'post', {score}, (response) ->
      console.log 'Score was posted to facebook', {score}

  # Get personal info
  # -----------------
  @getPersonalInfo: (callback) ->
    FB.api '/me', callback

  # Get friends
  # -----------------
  @getFriends: (callback, error) ->
    if @isLinked()
      FB.api '/me/friends?fields=installed', (response) =>
        if response.data
          callback?((friend for friend in response.data when friend.installed) || [])
        else
          error()
    else
      callback([])

  @getOtherFriends:(callback = null) ->
    if @isLinked()
      FB.api '/me/friends?fields=id,name,installed', (response) =>
        friends = (friend for friend in response.data when !friend.installed )
        if callback
          callback(friends)
        else
          friends
    else
      callback([])

  @getPermissions: (callback, errorCallback) ->
    FB.api '/me/permissions', (response) ->
      if response?.data?[0]
        callback?(permissions)
      else
        errorCallback?(response)

  @getLackingPermissions: (neededPermissions, callback, errorCallback) ->
    @getPermissions (permissions) ->
      callback?(p for p in neededPermissions when !!!permissions[p])
    , errorCallback

  # # Like the appli
  # # HAHA, like an Open Graph object. Not usable now, maybe later
  # # -------------------------------------------------
  # @likeAppli: (callback) ->
  #   FB.api '/me/og.likes',
  #     'post',
  #       object: "http://samples.ogp.me/226075010839791"
  #     (response) ->
  #       callback?(response)

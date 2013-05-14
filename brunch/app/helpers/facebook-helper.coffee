mediator      = require 'mediator'
utils         = require 'lib/utils'
PopUpHelper   = require 'helpers/pop-up-helper'
DeviceHelper  = require 'helpers/device-helper'
i18n          = require 'lib/i18n'
spinner       = require 'helpers/spinner-helper'

module.exports = class FacebookHelper
  self = @

  @logIn: (success, error) ->
    scope = 'email, user_location, user_birthday, publish_stream'

    if DeviceHelper.isIOS()
      spinner.start()

      FB.login( (response) =>
        if response.authResponse
          FB.api '/me', (res) =>
            params =
              id: res.id
              access_token: response.authResponse.accessToken
              expiration_date: new Date(response.authResponse.expirationTime).toISOString()

            Parse.FacebookUtils.logIn params,
              success: =>
                success()
              error: =>
                error(response)
        else
          error(response)
      , {scope})

    else
      Parse.FacebookUtils.logIn(scope, {success, error})

  # Friends invite request
  # ----------------------
  @friendRequest: (message, callback, errorCallback) ->
    doRequest = ->
      # if no message is no provided, return
      unless !!message
        return alert "FB.request: pas de message :("

      # if message is incorrect, return
      if message.length < 1 or message.length > 255
        return alert "FB.request: message doit faire entre 1 et 255 characteres (" + message.length + " actuellement)"

      # Checking FB is existant
      user = Parse.User.current()
      FacebookHelper.getOtherFriends (friends) =>
        notInstalledFriends = _.pluck(friends, 'id')
        FB.ui {method: 'apprequests', message: message, filters: [{name : 'invite friends', user_ids : _.difference(notInstalledFriends, user.get('fb_invited'))}]}, (response) =>

          # On iOs, response.to doesn't exist, and we receive "to%5B0%5D" (to[0]). Weiiiird.
          players_invited = if response.to then response.to else response['to%5B0%5D']
          players_invited = _.uniq(players_invited.concat(user.get('fb_invited')))

          # If we have a callback for this method, then use it (for exemple avoid rewarding?)
          user.set("fb_invited", players_invited)
          # Add a life at user per NEW friends added
          for friend in players_invited
            user.set("health", user.get("health")+1)

          user.save()
          if response
            callback?(response)
          else
            errorCallback?()
        , ->
          errorCallback?()

    unless @isLinked()
      @linkPlayer doRequest
    else
      doRequest()

  @friendRequestTo: (message, friend, callback = null, giveLife = false) ->
    doRequest = ->
      # if no message is no provided, return
      unless !!message
        return alert "FB.request: pas de message :("

      # if message is incorrect, return
      if message.length < 1 or message.length > 255
        return alert "FB.request: message doit faire entre 1 et 255 characteres (" + message.length + " actuellement)"

      # Checking FB is existant
      user = Parse.User.current()
      FB.ui {method: 'apprequests', message: message, to: friend}, (response) =>
        # if we have a callback for this method, then use it (for exemple avoid rewarding?)
        user.set("fb_invited", _.uniq(response.to.concat(user.get('fb_invited'))))
        if giveLife
          Parse.Cloud.run 'giveLife' , {friendsId: friend},
          success: (results) =>
            user.set('life_given', user.get('life_given').concat(results.get('fb_id')))
            console.log  results.get('health')
          error: (msg) =>
            console.log  msg
        else
          user.set("health", user.get("health")+1).save()
        if response and callback
          callback(response)
    unless @isLinked()
      @linkPlayer doRequest
    else
      doRequest()

  @isLinked: ->
    Parse.FacebookUtils.isLinked(Parse.User.current())

  # Link player from profile page
  # -----------------------------
  @linkPlayer: (success, error) ->
    Parse.FacebookUtils.link Parse.User.current(), 'email, user_location, user_birthday, publish_stream', {success, error}

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
          friends = (friend for friend in response.data when friend.installed)
          if !friends?
            friends = []
          callback(friends)
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
  # # Like the appli
  # # HAHA, like an Open Graph object. Not usable now, maybe later
  # # -------------------------------------------------
  # @likeAppli: (callback) ->
  #   FB.api '/me/og.likes',
  #     'post',
  #       object: "http://samples.ogp.me/226075010839791"
  #     (response) ->
  #       callback?(response)

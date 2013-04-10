mediator      = require 'mediator'
utils         = require 'lib/utils'
PopUpHelper   = require 'helpers/pop-up-helper'
i18n          = require 'lib/i18n'
spinner       = require 'helpers/spinner-helper'

module.exports = class FacebookHelper
  self = @

  # Friends invite request
  # ----------------------
  @friendRequest: (message, callback = null) ->
    doRequest = ->
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
  @getFriends: (callback) ->
    #friendList = ({id: fb_id} for fb_id in ['1509669172','599526180','100003164482205','100001321941779','1509669172','599526180','100003164482205','100001321941779', '1509669172','599526180','100003164482205','100001321941779'])
    #callback(friendList)
    if @isLinked()
      FB.api '/me/friends?fields=installed', (response) =>
        friends = (friend for friend in response.data when friend.installed)
        callback(friends)
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

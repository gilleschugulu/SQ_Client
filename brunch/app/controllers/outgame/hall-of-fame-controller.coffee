Controller      = require 'controllers/base/controller'
HallOfFameView  = require 'views/outgame/hall-of-fame-view'
mediator        = require 'mediator'
ConfigHelper    = require 'helpers/config-helper'
AnalyticsHelper = require 'helpers/analytics-helper'
FacebookHelper  = require 'helpers/facebook-helper'
i18n            = require 'lib/i18n'

module.exports = class HallOfFameController extends Controller
  historyURL: 'hall-of-fame'
  title: 'Hall of Fame'
  collection: null
  request : null

  fetchPlayers: (withFriends) =>
    ranking = if withFriends then @friendsArray else @globalArray
    @collection = []

    playerPosition = 0
    for entry, i in ranking
      @collection.push
        friend     : if entry.fb_id is Parse.User.current().get('fb_id') then false else withFriends
        rank       : entry.rank
        username   : (entry.username).slice(0,20)
        jackpot    : entry.score
        id         : entry.fb_id
        profilepic : if !!entry.fb_id then 'https://graph.facebook.com/'+entry.fb_id+'/picture' else null
      if entry.username is @user.get('username')
        playerPosition = i

    fbConnected = FacebookHelper.isLinked()
    noFriends = @collection.length <= 1
    @updateRanking(playerPosition, noFriends, fbConnected, withFriends)

  index: ->
    @user = Parse.User.current()
    @friendsArray = []
    @globalArray = []
    FacebookHelper.getOtherFriends (friends) =>
      @friendsToInvite(friends)
      Parse.Cloud.run 'getAllScore' , {rank : @user.get('rank'), userId : @user.id},
        success: (players) =>
          @globalArray = players
        error: ->
      FacebookHelper.getFriends (friends) =>
        friendsId = _.pluck(friends, 'id')
        Parse.Cloud.run 'getFriendsScore' , {friendsId: friendsId},
          success: (players) =>
            players.push Parse.User.current().attributes
            players = players.sort (f1, f2) ->
              f2.score - f1.score
            @friendsArray = players
            @fetchPlayers yes

    @targetDate = @getDate()
    @loadView null
    , =>
      params =
        targetDate : @targetDate
        rank   : mediator.user.get('rank')
        credits: mediator.user.get('credits')
        health : mediator.user.get('health')
      new HallOfFameView params
    , (view) =>
      view.delegate 'click', '#btn-friends', @onClickFriends
      view.delegate 'click', '#btn-global', @onClickGlobal
      view.delegate 'click', '.ask-friend', @askFriend
      view.delegate 'click', '#no-friends', @addFriends
      view.delegate 'click', '#no-fb-connected', @connectFacebook
      view.delegate 'click', '.invite-btn',@FacebookInvite
      @updateRanking() if @collection
    , {viewTransition: yes, music: 'outgame'}

  updateRanking: (i, noFriends, fbConnected, withFriends) =>
    @view?.updateRankingList @collection, i, noFriends, fbConnected, withFriends, @friendsToInvite

  onClickFriends: (e) =>
    if !$(e.target).hasClass('active')
      # Track Event
      AnalyticsHelper.trackEvent 'HallOfFame', 'Affichage des amis'
      @fetchPlayers yes
      @view.chooseList e.target

  onClickGlobal: (e) =>
    if !$(e.target).hasClass('active')
      # Track Event
      AnalyticsHelper.trackEvent 'HallOfFame', 'Affichage adversaires'
      @fetchPlayers no
      @view.chooseList e.target

  getDate: =>
    targetDate = new Date()
    targetDate.setHours(0)
    targetDate.setMinutes(0)
    targetDate.setSeconds(0)
    targetDate.setDate(targetDate.getDate() - targetDate.getDay() + 7)
    return targetDate

  askFriend: (e) =>
    if !$(e.target).hasClass('asked')
      @view.askFriend e.target
      id = $(e.currentTarget).data 'id'
      FacebookHelper.friendRequestTo(i18n.t('controller.home.facebook_invite_message'), id, null, true)

  addFriends: =>
    FacebookHelper.friendRequest i18n.t('controller.home.facebook_invite_message')

    #TODO : Think to add callbacks
  connectFacebook: =>
    FacebookHelper.linkPlayer() unless FacebookHelper.isLinked()

  friendsToInvite:(friends) =>
    friends2 = _.pluck(friends, 'id')
    user = Parse.User.current()
    tmp = _.first(_.shuffle(_.difference(friends2, user.get('fb_invited'))), 3)
    results = []
    for friend in tmp
      FB.api '/'+friend+'?fields=name', (response)->
        results.push(response)
    @friendsToInvite  = results

  FacebookInvite: (event) =>
    id = $(event.currentTarget).data 'id'
    FacebookHelper.friendRequestTo(i18n.t('controller.home.facebook_invite_message'), id)
    @view.takeOffFriend(event.currentTarget)

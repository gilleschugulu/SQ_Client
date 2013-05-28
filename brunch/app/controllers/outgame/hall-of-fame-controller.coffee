Controller      = require 'controllers/base/controller'
HallOfFameView  = require 'views/outgame/hall-of-fame-view'
mediator        = require 'mediator'
ConfigHelper    = require 'helpers/config-helper'
AnalyticsHelper = require 'helpers/analytics-helper'
FacebookHelper  = require 'helpers/facebook-helper'
i18n            = require 'lib/i18n'
_               = require 'underscore'

module.exports = class HallOfFameController extends Controller
  historyURL: 'hall-of-fame'
  title: 'Hall of Fame'
  collection: null
  request : null
  nextRoute: null

  displayPlayers: (withFriends) =>
    ranking = if withFriends then @friendsArray else @globalArray
    players = []

    playerPosition = 0
    user = Parse.User.current()
    players = _.map ranking, (entry, index) ->
      if entry.username is user.get('username')
        playerPosition = index
      data = 
        friend     : if entry.fb_id is user.get('fb_id') then false else withFriends
        rank       : entry.rank
        username   : entry.username
        jackpot    : entry.score
        id         : entry.fb_id
        profilepic : if !!entry.fb_id then 'https://graph.facebook.com/' + entry.fb_id + '/picture' else null

    if withFriends and FacebookHelper.isLinked() is false
      @view?.updateRankingListNotConnected()
    else if withFriends and players.length <= 1
      @view?.updateRankingListNoFriends()
    else
      options = 
        fbConnected:    FacebookHelper.isLinked()
        playerPosition: playerPosition

      @view?.updateRankingList players, @friendsToInvite, options

  fetchGlobalPlayers: ->
    Parse.Cloud.run 'getAllScore' , {rank : @user.get('rank'), userId : @user.id},
      success: (players) =>
        Parse.Cloud.run 'getRanksPercentages' , {rank : @user.get('rank')},
          success: (percentages) =>
            @percentages = percentages
            @globalArray = players
      error: ->

  fetchFriends: ->
    FacebookHelper.getOtherFriends (friends) =>
      FacebookHelper.getFriends (friends) =>
        friendsId = _.pluck(friends, 'id')
        Parse.Cloud.run 'getFriendsScore' , {friendsId: friendsId},
          success: (players) =>
            players.push Parse.User.current().attributes
            players = players.sort (f1, f2) ->
              f2.score - f1.score
            @friendsArray = players
            @displayPlayers yes

  index: (params) ->
    @nextRoute = params.nextRoute
    @user = Parse.User.current()
    @friendsArray = null
    @globalArray = null
    @fetchGlobalPlayers()
    @fetchFriends()

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
      view.delegate 'click', '.invite-btn', @FacebookInvite
      view.delegate 'click', '.home-btn', @onClickHomeBtn
      # @updateRanking() if @collection
    , {viewTransition: yes}

  onClickFriends: (e) =>
    if !$(e.target).hasClass('active')
      # Track Event
      AnalyticsHelper.trackEvent 'HallOfFame', 'Affichage des amis'
      @displayPlayers yes
      @view.chooseList e.target

  onClickGlobal: (e) =>
    if !$(e.target).hasClass('active')
      # Track Event
      AnalyticsHelper.trackEvent 'HallOfFame', 'Affichage adversaires'
      @displayPlayers no
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

  onClickHomeBtn: =>
    @redirectTo @nextRoute

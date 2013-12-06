Controller      = require 'controllers/base/controller'
HallOfFameView  = require 'views/outgame/hall-of-fame-view'
mediator        = require 'mediator'
ConfigHelper    = require 'helpers/config-helper'
AnalyticsHelper = require 'helpers/analytics-helper'
FacebookHelper  = require 'helpers/facebook-helper'
i18n            = require 'lib/i18n'
PopUpHelper     = require 'helpers/pop-up-helper'
_               = require 'underscore'

module.exports = class HallOfFameController extends Controller
  historyURL: 'hall-of-fame'
  title: 'Classement'
  collection: null
  request : null
  nextRoute: null
  friendsPlayers : null
  globalPlayers : null

  displayPlayers: (withFriends, alltime = no) =>
    if withFriends
      ranking = @friendsPlayers
      if alltime
        ranking.sort (a, b) -> b.best_score - a.best_score
      else
        ranking.sort (a, b) -> b.score - a.score
    else
      ranking = @globalPlayers

    players = []

    playerPosition = 0
    user = Parse.User.current()
    given = user.get('life_given') || []
    players = _.map ranking, (entry, index) ->
      if entry.username is user.get('username')
        playerPosition = index
      data =
        friend   : entry.fb_id isnt user.get('fb_id') and withFriends
        got_life : $.inArray(entry.fb_id, given) >= 0
        rank     : entry.rank
        username : entry.username
        jackpot  : if alltime then entry.best_score else entry.score
        fb_id    : entry.fb_id
        position : if withFriends then index + 1 else entry.position
        range    : if withFriends is undefined else entry.range_name

    options =
      fbConnected:    FacebookHelper.isLinked()
      playerPosition: playerPosition
    if withFriends and !options.fbConnected
      @view?.updateRankingListNotConnected()
    else if withFriends and players.length <= 1
      @view?.updateRankingListNoFriends()
    else
      @view?.updateRankingList players, @friendsToInvite, options

  fetchGlobalPlayers: ->
    Parse.Cloud.run 'leaderboard', {rank : @user.get('rank'), userId : @user.id},
      success: (results) =>
        @globalPlayers = _.uniq results.players, (player) ->
          player.position
        @globalPlayers.sort (a, b) -> a.position - b.position

  fetchFriends: =>
    FacebookHelper.getFriends (friends) =>
      (friendsId = _.pluck friends, 'id').push @user.get('fb_id')
      Parse.Cloud.run 'leaderboard_friends', {friendsId},
        success: (players) =>
          @friendsPlayers = players
          @displayPlayers yes, yes

  index: (params) ->
    @nextRoute = params.nextRoute
    @user = Parse.User.current()
    @fetchGlobalPlayers()
    @fetchFriends()

    @loadView null
    , =>
      params =
        targetDate : @getDate()
        rank   : mediator.user.get('rank')
        credits: mediator.user.get('credits')
        health : mediator.user.get('health')
      new HallOfFameView params
    , (view) =>
      view.delegate 'click', '#btn-friends-alltime', (e) => @onClickFriends(e, yes)
      view.delegate 'click', '#btn-friends', @onClickFriends
      view.delegate 'click', '#btn-global', @onClickGlobal
      view.delegate 'click', '#btn-invite', @onClickFacebook
      view.delegate 'click', '.ask-friend', @giveLifeToFriend
      view.delegate 'click', '#no-friends', @addFriends
      view.delegate 'click', '#no-fb-connected', @connectFacebook
      view.delegate 'click', '.invite-btn', @FacebookInvite
      view.delegate 'click', '.home-btn', @onClickHomeBtn
    , {viewTransition: yes}

  onClickFriends: (e, alltime = no) =>
    if !$(e.target).hasClass('active')
      # Track Event
      if alltime
        AnalyticsHelper.trackEvent 'Classement', 'Click', 'Affichage des amis All Time'
      else
        AnalyticsHelper.trackEvent 'Classement', 'Click', 'Affichage des amis Tournoi'
      @displayPlayers yes, alltime
      @view.chooseList e.target
      @view.showLevel no

  onClickGlobal: (e) =>
    if !$(e.target).hasClass('active')
      # Track Event
      AnalyticsHelper.trackEvent 'Classement', 'Click', 'Affichage adversaires'
      @displayPlayers no
      @view.chooseList e.target
      @view.showLevel yes

  getDate: =>
    targetDate = new Date()
    targetDate.setUTCHours(23)
    targetDate.setUTCMinutes(0)
    targetDate.setUTCSeconds(0)
    targetDate.setUTCDate(targetDate.getUTCDate() - targetDate.getUTCDay() + 7)
    return targetDate

  giveLifeToFriend: (e) =>
    err = -> PopUpHelper.initialize {message: i18n.t('controller.hof.life_giveaway.error'), title: 'Action impossible', key: 'appRequest-error'}

    id = ($(e.currentTarget).data 'id').toString()
    user = Parse.User.current()
    name = (f.username for f in @friendsPlayers when f.fb_id == id)[0]

    if !$(e.target).hasClass('asked') and $.inArray(id, user.get('life_given')) < 0
      Parse.Cloud.run 'give_life' , {friendsId: id},
        success: (response) =>
          if response.id == id
            user.get('life_given').push response.id
            user.save()
            @view.lifeGiven e.target
            PopUpHelper.initialize {message: i18n.t('controller.hof.life_giveaway.success', name, null), title: 'Youpi', key: 'appRequest-error'}
          else
            err()
        error: err
    else
      @view.lifeGiven e.target
      PopUpHelper.initialize {message: i18n.t('controller.hof.life_giveaway.already_given', name, null), title: 'Action impossible', key: 'appRequest-error'}

  addFriends: =>
    FacebookHelper.friendRequest i18n.t('controller.home.facebook_invite_message')

  connectFacebook: =>
    unless FacebookHelper.isLinked()
      FacebookHelper.linkPlayer @fetchFriends

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

  onClickFacebook: =>
    AnalyticsHelper.trackEvent 'Classement', 'Click', 'Inviter amis'
    FacebookHelper.getOtherFriends (friends) =>
      # Check if everyone is invited
      if _.difference(_.pluck(friends, 'id'), Parse.User.current().get('fb_invited')).length < 1 and FacebookHelper.isLinked()
         popUp.initialize {message: i18n.t('controller.home.app_request.error'), title: 'Action impossible', key: 'appRequest-error'}
      else
        FacebookHelper.friendRequest i18n.t('controller.home.facebook_invite_message'), (bonusHealth) =>
          if bonusHealth > 0
            @view.updateNumbers Parse.User.current().get('health')
            popUp.initialize {message: i18n.t('controller.home.app_request.success_bonus', bonusHealth, null), title: 'Invitations envoyées', key: 'appRequest-success'}
          else
            popUp.initialize {message: i18n.t('controller.home.app_request.success'), title: 'Invitations envoyées', key: 'appRequest-success'}
        , =>
          popUp.initialize {message: i18n.t('controller.home.app_request.error'), title: 'Action impossible', key: 'appRequest-error'}
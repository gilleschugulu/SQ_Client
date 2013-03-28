Controller      = require 'controllers/base/controller'
HallOfFameView  = require 'views/outgame/hall-of-fame-view'
ApiCallHelper   = require 'helpers/api-call-helper'
mediator        = require 'mediator'
ConfigHelper    = require 'helpers/config-helper'
AnalyticsHelper = require 'helpers/analytics-helper'

module.exports = class HallOfFameController extends Controller
  historyURL: 'hall-of-fame'
  title: 'Hall of Fame'
  collection: null
  request : null

  fetchPlayers: (withFriends) =>
    @friend = if withFriends then true else false
    ranking = if withFriends then @friendsArray else @globalArray
    @collection = []
    for i in [0..ranking.length-1]
      @collection[i] =
        friend     : @friend
        rank       : ranking[i].attributes.order
        username   : ranking[i].attributes.username
        jackpot    : ranking[i].attributes.score
        profilepic : if Math.random() > 0.49 then 'https://graph.facebook.com/sergio.chugulu/picture' else null
    # params =
    #   uuid   : mediator.user.get('uuid')
    #   friends: withFriends
    # @request?.abort()
    # @request = ApiCallHelper.fetch.getLeaderboards params, (@collection) =>
    #   @request = null
      @updateRanking()

  index: ->
    user = Parse.User.current()
    @friendsArray = new Array();
    @globalArray = new Array();
    Parse.Cloud.run('getGlobalScores', {id : user.id , rank : user.get('rank')}, {
      success: (result) =>
        @globalArray = result
        @friendsArray = result
        @fetchPlayers yes
      error: (error) =>
        console.log error
    });



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
      @updateRanking() if @collection
    , {viewTransition: yes, music: 'outgame'}

  updateRanking: =>
    @view?.updateRankingList @collection

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

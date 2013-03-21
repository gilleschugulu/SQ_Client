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
    @collection = {}
    self_index = parseInt(Math.random() * 21)
    for i in [1..21]
      if i is self_index
        t = 'self'
      else
        t = 'opponent'
        if withFriends
          t = if Math.random() > 0.49 then 'friend' else 'opponent'
      @collection[i] =
        username  : "#{t}_#{i}"
        jackpot   : Math.ceil(Math.random() * 50000)
        profilepic: if Math.random() > 0.49 then 'https://graph.facebook.com/sergio.chugulu/picture' else null
        type      : t
    # params =
    #   uuid   : mediator.user.get('uuid')
    #   friends: withFriends
    # @request?.abort()
    # @request = ApiCallHelper.fetch.getLeaderboards params, (@collection) =>
    #   @request = null
      @updateRanking()

  index: ->
    @fetchPlayers yes

    @loadView null
    , =>
      params =
        rank   : mediator.user.get('rank')
        credits: mediator.user.get('credits')
      new HallOfFameView params
    , (view) =>
      view.delegate 'click', '#btn-game-center', @onClickGameCenter
      view.delegate 'click', '#btn-friends', @onClickFriends
      view.delegate 'click', '#btn-opponents', @onClickOpponents
      @updateRanking() if @collection
    , {viewTransition: yes, music: 'outgame'}

  updateRanking: =>
    @view?.updateRankingList @collection

  onClickGameCenter: =>
    # Track Event
    AnalyticsHelper.trackEvent 'HallOfFame', 'Affichage de Game Center'

    console.log "GC"
    lb = ConfigHelper.config.gamecenter.leaderboard
    if lb
      GameCenter?.showLeaderboard lb
    else
      alert('pas de leaderboard')

  onClickFriends: (e) =>
    # Track Event
    AnalyticsHelper.trackEvent 'HallOfFame', 'Affichage des amis'

    console.log "FRIENDS"
    @fetchPlayers yes
    @view.chooseList e.target

  onClickOpponents: (e) =>
    # Track Event
    AnalyticsHelper.trackEvent 'HallOfFame', 'Affichage adversaires'

    console.log "OPPONENTS"
    @fetchPlayers no
    @view.chooseList e.target

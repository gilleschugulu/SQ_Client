Controller      = require 'controllers/base/controller'
PlayerModel     = require 'models/ingame/player-model'
GameOverView    = require 'views/ingame/game-over-view'
SoundHelper     = require 'helpers/sound-helper'
I18n            = require 'lib/i18n'
GameStatHelper  = require 'helpers/game-stat-helper'

module.exports = class GameOverController extends Controller
  title: 'Game Over'
  bestJackpot: no

  index: (success, params) ->
    @loadView 'game-over'
    , =>
      GameStatHelper.setBestScore(params.jackpot)
      GameStatHelper.incrementSumScore(params.jackpot)
      GameStatHelper.saveStats()

      jackpot    = parseInt(params.jackpot)
      reward     = @getRewardAmount jackpot
      endMessage = I18n.t "controller.game_over.end_message.#{@getEndMessageKey(jackpot)}"
      user       = @updateUser(Parse.User.current(), jackpot, reward)

      params.jackpot =
        value: jackpot
        best: user.get('score')
        bestJackpot: @bestJackpot

      stats = GameStatHelper.getEndGameScoreStat()
      stats.game_row = user.get('game_row')
      params.stats = _.map stats, (val, key) ->
        name: key
        number: val
        text: I18n.t('controller.game_over.stats.' + key)

      view = new GameOverView {success, params, reward, endMessage, player: {health: user.get('health'), credits: user.get('credits')}}
      user.increment('score', user.get('game_row')).save()

      view   # Must always return @view

    , (view) =>
      view.delegate 'click', '#replay', => @redirectTo 'game'
      view.delegate 'click', 'a', @onClickALink
    , {viewTransition: yes}


  lost: (params) ->
    @index no, params

  won: (params) ->
    @index yes, params

  getRewardAmount: (score) ->
    return 0 if score < 1000
    return 10 if score < 2000
    return 20 if score < 5000
    return 50 if score < 10000
    100

  getEndMessageKey: (score) ->
    return 'msg1k' if score < 1000
    return 'msg2k' if score < 2000
    return 'msg5k' if score < 5000
    return 'msg10k' if score < 10000
    'msg10kplus'

  updateUser: (user, jackpot, reward) ->
    user.increment('credits', reward).increment('game_row')

    if jackpot > user.get('score')
      user.set('score', jackpot)
      @bestJackpot = yes

    user

  onClickALink: (e) =>
    links =
      '#home' : 'Home'
      '#game' : 'Rejouer'
    super e, 'Game Over', links
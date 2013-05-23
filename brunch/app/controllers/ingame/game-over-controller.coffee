Controller      = require 'controllers/base/controller'
PlayerModel     = require 'models/ingame/player-model'
GameOverView    = require 'views/ingame/game-over-view'
SoundHelper     = require 'helpers/sound-helper'
I18n            = require 'lib/i18n'
GameStatHelper  = require 'helpers/game-stat-helper'

module.exports = class GameOverController extends Controller

  bestJackpot: no

  index: (success, params) ->
    @loadView 'game-over'
    , =>
      GameStatHelper.setBestScore(params.jackpot)
      GameStatHelper.incrementSumScore(params.jackpot)
      GameStatHelper.saveStats()

      jackpot = parseInt(params.jackpot)
      user = @updateUser(Parse.User.current(), jackpot)
      jackpot += user.get('game_row') unless @bestJackpot

      params.jackpot =
        value: jackpot
        best: user.get('score')
        bonus: user.get('game_row')
        bestJackpot: @bestJackpot

      params.stats = _.map GameStatHelper.getEndGameScoreStat(), (val, key) ->
        name: key
        number: val
        text: I18n.t('controller.game_over.stats.' + key)

      new GameOverView {success, params, player: {health: user.get('health'), credits: user.get('credits')}}

    , (view) =>
      view.delegate 'click', '#replay', => @redirectTo 'game'
      setTimeout view.bonusAppear, 200
    , {viewTransition: yes, music: 'game-over'}

  lost: (params) ->
    @index no, params

  won: (params) ->
    @index yes, params


  updateUser: (user, jackpot) ->
    user.increment('credits', 10).increment('game_row')

    if jackpot > user.get('score')
      user.set('score', jackpot)
      @bestJackpot = yes
      console.log 'Best SCORE !', user.get('score')
    user.increment('score', user.get('game_row'))
    console.log 'new score is', user.get('score')

    user.save()
    user
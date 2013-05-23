Controller      = require 'controllers/base/controller'
PlayerModel     = require 'models/ingame/player-model'
GameOverView    = require 'views/ingame/game-over-view'
SoundHelper     = require 'helpers/sound-helper'
I18n            = require 'lib/i18n'
GameStatHelper  = require 'helpers/game-stat-helper'

module.exports = class GameOverController extends Controller

  index: (success, params) ->
    @loadView 'game-over'
    , =>
      GameStatHelper.setBestScore(params.jackpot)
      GameStatHelper.incrementSumScore(params.jackpot)
      GameStatHelper.saveStats()

      jackpot = parseInt(params.jackpot)
      user = @updateUser(Parse.User.current(), jackpot)

      params.stats = _.map GameStatHelper.getEndGameScoreStat(), (val, key) ->
        name: key
        number: val
        text: I18n.t('controller.game_over.stats.' + key)

      new GameOverView {success, params, player: {health: user.get('health'), credits: user.get('credits')}}

    , (view) =>
      view.delegate 'click', '#replay', => @redirectTo 'game'
    , {viewTransition: yes, music: 'game-over'}

  lost: (params) ->
    @index no, params

  won: (params) ->
    @index yes, params


  updateUser: (user, jackpot) ->
    user.increment('credits', 10).increment('game_row')

    if jackpot > user.get('score')
      user.set('score', jackpot)
    user.increment('score', game_row)

    user.save()
    user
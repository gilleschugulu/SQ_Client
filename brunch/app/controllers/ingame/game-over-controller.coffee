Controller   = require 'controllers/base/controller'
PlayerModel  = require 'models/ingame/player-model'
GameOverView = require 'views/ingame/game-over-view'
SoundHelper  = require 'helpers/sound-helper'
I18n         = require 'lib/i18n'

module.exports = class GameOverController extends Controller

  index: (success, params) ->
    @loadView 'game-over'
    , =>
      user = Parse.User.current()

      params.stats = [
        {name: 'nb_questions', number: 27, text: I18n.t('controller.game_over.stats.' + 'nb_questions')}
        {name: 'good_answers', number: 16, text: I18n.t('controller.game_over.stats.' + 'good_answers')}
        {name: 'wrong_answers', number: 11, text: I18n.t('controller.game_over.stats.' + 'wrong_answers')}
        {name: 'best_row', number:  5, text: I18n.t('controller.game_over.stats.' + 'best_row')}
      ]

      new GameOverView {success, params, player: {health: user.health, credits: user.credits}}
    , (view) =>
      view.delegate 'click', '#replay', => @redirectTo 'game'
    , {viewTransition: yes, music: 'game-over'}

  lost: (params) ->
    @index no, params

  won: (params) ->
    @index yes, params

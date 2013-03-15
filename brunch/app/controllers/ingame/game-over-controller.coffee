Controller   = require 'controllers/base/controller'
PlayerModel  = require 'models/ingame/player-model'
GameOverView = require 'views/ingame/game-over-view'
SoundHelper  = require 'helpers/sound-helper'

module.exports = class GameOverController extends Controller

  index: (success, params) ->
    @loadView 'game-over'
    , =>
      new GameOverView {success, params}
    , (view) =>
      view.delegate 'click', '#replay', => @redirectTo 'game'
    , {viewTransition: yes, music: 'game-over'}

  lost: (params) ->
    @index no, params

  won: (params) ->
    @index yes, params

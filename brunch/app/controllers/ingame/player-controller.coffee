Controller = require 'controllers/base/controller'
Model = require 'models/ingame/player-model'
mediator = require 'mediator'

module.exports = class PlayersController extends Controller

  initialize: (data) ->
    mediator.user = new Model()
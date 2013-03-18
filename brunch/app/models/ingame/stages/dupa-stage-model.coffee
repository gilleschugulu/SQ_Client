Stage = require 'models/ingame/stage-model'

module.exports = class DupaStage extends Stage
  currentThresholdIndex: 0

  getHumanPlayer: ->
    @get('player')

  setPlayers: (players) ->
    players = (player.configure(@get('config').player) for player in players)
    @set 'player', players[0]
    @

  playerMadeError: (player) ->
    @currentThresholdIndex = 0
    player

  playerMadeSuccess: (player) ->
    thresholds = @getConfigValue('thresholds')
    player.addJackpot(thresholds[@currentThresholdIndex])
    @currentThresholdIndex++ if @currentThresholdIndex < thresholds.length
    player

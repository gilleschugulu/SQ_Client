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

  playerMadeSuccess: (player, doubleScore) ->
    jackpot = @getCurrentThreshold()
    jackpot *= 2 if doubleScore
    player.addJackpot jackpot
    @increaseThreshold()
    player

  increaseThreshold: ->
    @currentThresholdIndex++ if @currentThresholdIndex < @getConfigValue('thresholds').length - 1

  getCurrentThreshold: ->
    @getConfigValue('thresholds')[@currentThresholdIndex]
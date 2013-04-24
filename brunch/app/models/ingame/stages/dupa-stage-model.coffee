Stage = require 'models/ingame/stage-model'

module.exports = class DupaStage extends Stage
  currentThresholdIndex: 0
  questionDifficulty: 1

  getHumanPlayer: ->
    @get('player')

  setPlayers: (players) ->
    players = (player.configure(@get('config').player) for player in players)
    @set 'player', players[0]
    @

  playerMadeError: (player) ->
    @currentThresholdIndex = 0
    @questionDifficulty = 1
    player

  playerMadeSuccess: (player, doubleScore) ->
    jackpot = @getCurrentThreshold()
    jackpot *= 2 if doubleScore
    player.addJackpot jackpot
    @increaseThreshold()
    player

  increaseThreshold: ->
    if @currentThresholdIndex < @getConfigValue('thresholds').length - 1
      @currentThresholdIndex++
      # TODO : Refactor this shit !
      if @currentThresholdIndex < 3
        @questionDifficulty = 1
      else if @currentThresholdIndex < 6
        @questionDifficulty = 2
      else if @currentThresholdIndex < 8
        @questionDifficulty = 3
      else
        @questionDifficulty = 4



  getCurrentThreshold: ->
    @getConfigValue('thresholds')[@currentThresholdIndex]

  getNextQuestion: (reset = no) ->
    @questionIndex = -1 if reset
    ++@questionIndex

    # @get('questions')[@questionIndex % @get('questions').length]

    questions = @get('questions')[@questionDifficulty]
    questions[@questionIndex % questions.length]


  getCurrentQuestion: ->
    questions = @get('questions')[@questionDifficulty]
    questions[@questionIndex % questions.length]

    # @get('questions')[@questionIndex % @get('questions').length]
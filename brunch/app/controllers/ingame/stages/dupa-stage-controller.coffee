StageController = require 'controllers/ingame/stage-controller'
DupaStageView   = require 'views/ingame/stages/dupa-stage-view'
Timer           = require 'helpers/timer-helper'
i18n            = require 'lib/i18n'

module.exports = class DupaStageController extends StageController
  timer: null

  start: ->
    @view = new DupaStageView {stage : {@name, @type}, thresholds: @model.getConfigValue('thresholds'), bonus: @model.get('player').getBonuses()}
    @timer = new Timer((duration) => @view.updateTimer(duration))
    super
    @view.unDim =>
      @timer.schedule @model.getConfigValue('answerTime'), 0, =>
        @view.updateTimer(1)
        setTimeout =>
          @finishStage()
        , 200
      @view.updateJackpot(0, 0)
      @view.welcome @askNextQuestion

      @view.delegate 'click', '.bonus', (event) =>
        @timer.stop()
        @view.chooseBonus event.currentTarget, (bonusName) =>
          if @model.get('player').consumeBonus(bonusName)
            console.log 'VNIUEWONVEIWOJFEOIJFEWIOJFEWOIFJEWIOFJEWIOFJEWO'
            @view.updateBonus event.currentTarget, @model.get('player').getBonusQuantity(bonusName)

  askNextQuestion: =>
    @timer.start()
    player = @model.getHumanPlayer()
    question = @model.getNextQuestion()

    @view.showQuestion question, =>
      @view.undelegateSingle 'click', '.proposition'

      # if @paused
      #   @onResume = => @playerDidAnswer player, question, no
      # else
      #   @playerDidAnswer player, question, no

      @view.delegateSingleOnce 'click', '.proposition', (event) =>
        @timer.stop()
        @view.chooseProposition event.currentTarget, (propositionId) =>
          result = question.isCorrectAnswer propositionId
          @view.updateAnswerButton propositionId, result, =>
            @playerDidAnswer player, question, result
          , question

  playerDidAnswer: (player, question, result) =>
    if result then @model.playerMadeSuccess(player) else @model.playerMadeError(player)
    @view.updateJackpot player.get('jackpot'), @model.currentThresholdIndex
    @askNextQuestion()

  beforeFinishStage: (player) ->
    textKey = if player.get('hp') is 5 then 'master_piece' else 'not_master_piece'
    @view.finishMessage textKey, [null, player.get('jackpot') + '', player.get('hp') + ''], @finishStage
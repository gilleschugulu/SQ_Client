StageController = require 'controllers/ingame/stage-controller'
DupaStageView   = require 'views/ingame/stages/dupa-stage-view'
Timer           = require 'helpers/timer-helper'
i18n            = require 'lib/i18n'
utils           = require 'lib/utils'

module.exports = class DupaStageController extends StageController
  timer: null
  bonusFiftyFiftyUsed: false
  bonusMassUsed: false

  start: ->
    t = @model.getConfigValue('thresholds').slice(0).reverse()
    @view = new DupaStageView {stage : {@name, @type}, thresholds: t, bonus: @model.get('player').getBonuses(), time : @model.getConfigValue('answerTime')}
    @timer = new Timer((duration) => @view.updateTimer(duration))
    super
    @view.unDim =>
      @timer.schedule @model.getConfigValue('answerTime'), 0, =>
        @view.updateTimer(1)
        setTimeout =>
          @finishStage()
        , 200
      @view.updateJackpot(0, @model.getCurrentThreshold())
      @view.welcome @askNextQuestion

      @view.delegate 'click', '.bonus', (event) =>
        @view.chooseBonus event.currentTarget, (bonusName) =>
          if @canUseBonus(bonusName) and @model.get('player').consumeBonus(bonusName)
            @timer.stop()
            @view.updateBonus event.currentTarget, @model.get('player').getBonusQuantity(bonusName)
            @executeBonus(bonusName)

  askNextQuestion: =>
    @bonusFiftyFiftyUsed = no
    @bonusMassUsed = no
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
    @view.updateJackpot player.get('jackpot'), @model.getCurrentThreshold()
    @askNextQuestion()

  beforeFinishStage: (player) ->
    textKey = if player.get('hp') is 5 then 'master_piece' else 'not_master_piece'
    @view.finishMessage textKey, [null, player.get('jackpot') + '', player.get('hp') + ''], @finishStage


  ### Bonus handling ###

  canUseBonus: (bonusName) ->
    return no if bonusName == 'mass' and @bonusMassUsed
    return no if bonusName == 'fifty_fifty' and @bonusFiftyFiftyUsed
    return no if bonusName == 'add_time' and @timer.duration >= @model.getConfigValue('time_bonus_threshold')
    true

  executeBonus: (bonusName) ->
    console.log 'Execute bonus : ', bonusName
    @[$.zepto.camelize('executeBonus-' + utils.dasherize(bonusName))]?()
    @timer.start()

  # Remove 2 answers
  executeBonusFiftyFifty: ->
    @view.hideSomeAnswers(@model.getCurrentQuestion().getWrongAnwers(2))
    @bonusFiftyFiftyUsed = yes

  # Ask the crowd 
  executeBonusMass: ->
    @view.displayMass(@model.getCurrentQuestion().getPonderatedAnwers())
    @bonusMassUsed = yes

  # Skip a threshold ? 
  executeBonusDouble: ->

  # Add x time
  executeBonusAddTime: ->
    @timer.adjustDuration(@model.getConfigValue('timeBonus'))

  # Skip question
  executeBonusSkip: ->
    @askNextQuestion()
StageController = require 'controllers/ingame/stage-controller'
DupaStageView   = require 'views/ingame/stages/dupa-stage-view'
Timer           = require 'helpers/timer-helper'
i18n            = require 'lib/i18n'
utils           = require 'lib/utils'
GameStatHelper  = require 'helpers/game-stat-helper'

module.exports = class DupaStageController extends StageController
  timer: null
  bonusFiftyFiftyUsed: false
  bonusMassUsed: false
  bonusDoubleUsed: false
  row: 0
  startTime: null

  start: ->
    t = @model.getConfigValue('thresholds').slice(0).reverse()
    @view = new DupaStageView {stage : {@name, @type}, thresholds: t, bonus: @model.get('player').getBonuses(), time : @model.getConfigValue('answerTime')}
    @timer = new Timer((duration) =>
      @view.updateTimer(duration)
    )
    GameStatHelper.incrementGamesPlayedCount()
    super
    @view.unDim =>
      @timer.schedule @model.getConfigValue('answerTime'), 0, =>
        setTimeout =>
          @beforeFinishStage()
        , 200
      @view.updateJackpot(0, @model.getCurrentThreshold())
      @view.welcome @askNextQuestion

      @view.delegate 'click', '.bonus', (event) =>
        @view.chooseBonus event.currentTarget, (bonusName) =>
          if @canUseBonus(bonusName) #and @model.get('player').consumeBonus(bonusName)
            @view.updateBonus event.currentTarget, @model.get('player').getBonusQuantity(bonusName)
            @executeBonus(bonusName)

  askNextQuestion: =>
    @startTime = new Date().getTime()
    @view.doubleScoreDeactivated() if @bonusDoubleUsed

    @timer.start()
    @bonusFiftyFiftyUsed = no
    @bonusMassUsed = no
    @bonusDoubleUsed = no
    player = @model.getHumanPlayer()
    question = @model.getNextQuestion()

    @view.showQuestion question, =>
      @view.undelegateSingle 'click', '.proposition'
      @view.delegateSingleOnce 'click', '.proposition', (event) =>
        @view.chooseProposition event.currentTarget, (propositionId) =>
          result = question.isCorrectAnswer propositionId
          @view.updateAnswerButton propositionId, result, =>
            @playerDidAnswer player, question, result
          , question

  playerDidAnswer: (player, question, result) =>
    oldJackpot = @model.getCurrentThreshold()

    if result
      @model.playerMadeSuccess(player, @bonusDoubleUsed)
      @row++
    else
      @model.playerMadeError(player)
      GameStatHelper.setBestRow(@row) if @row > 0
      @row = 0

    GameStatHelper.incrementAnswersCount(result, question.get('category'))
    GameStatHelper.incrementSumTimeQuestion((new Date().getTime()) - @startTime)

    @view.updateJackpot player.get('jackpot'), @model.getCurrentThreshold(), {result, oldJackpot}
    @askNextQuestion()

  beforeFinishStage: (player) =>
    GameStatHelper.setBestRow(@row) if @row > 0
    @finishStage()


  ### Bonus handling ###

  canUseBonus: (bonusName) ->
    return no if bonusName == 'mass' and @bonusMassUsed
    return no if bonusName == 'fifty_fifty' and @bonusFiftyFiftyUsed
    return no if bonusName == 'double' and @bonusDoubleUsed
    return no if bonusName == 'add_time' and @model.getConfigValue('timeBonus') + Math.floor(@timer.duration) > @model.getConfigValue('answerTime')
    true

  executeBonus: (bonusName) ->
    @[$.camelCase('executeBonus-' + utils.dasherize(bonusName))]?()

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
    @view.doubleScoreActivated()
    @bonusDoubleUsed = yes

  # Add x time
  executeBonusAddTime: ->
    @timer.adjustDuration(@model.getConfigValue('timeBonus'))

  # Skip question
  executeBonusSkip: ->
    @askNextQuestion()
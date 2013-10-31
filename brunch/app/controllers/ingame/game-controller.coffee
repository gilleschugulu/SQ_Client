Controller           = require 'controllers/base/controller'
mediator             = require 'mediator'
Player               = require 'models/ingame/player-model'
Factory              = require 'helpers/factory-helper'
ConfigHelper         = require 'helpers/config-helper'
config               = require 'config/environment-config'
AnalyticsHelper      = require 'helpers/analytics-helper'
FacebookHelper       = require 'helpers/facebook-helper'
PopUpHelper          = require 'helpers/pop-up-helper'
i18n                 = require 'lib/i18n'
QuestionsList        = require 'config/questions/questions'
GameStatHelper       = require 'helpers/game-stat-helper'

module.exports = class GameController extends Controller
  historyURL: 'game'
  title: 'Jeu'

  currentController: null
  currentStageIndex: -1
  stageName        : null   # stage name that will be sent to the server
  i18nStageName    : null
  loaded           : no
  game             : {}
  players          : []     # Move this to game model ?
  stages: [{
    name: 'dupa'
    type: 'dupa'
    i18n_key: 'dupa'
  }]

  # Workflow
  #  =>
  #  When both done, load XStageController, where X is the current stage
  #  | Listen on event stage:finish, to increment currentStageIndex, and launch new loop
  # ------------------------------------------------------------------------------------
  index: =>
    AnalyticsHelper.trackPageView @title

    @payGame =>
      PushNotifications?.block() # dont show push stuff while playing
      @subscribeEvent 'stage:finish', @finishGame
      @subscribeEvent 'game:finish', @finishGame
      @loadGame =>
        # return @finishGame()
        if @loaded
          @loadNextStage()


  payGame: (callback) ->
    user = Parse.User.current()
    if config.pay_game and user.get('health') <= 0
      AnalyticsHelper.trackEvent @title, 'Erreur', 'Pas assez de vies'
      PopUpHelper.initialize
        title  : i18n.t 'controller.game.not_enough_health.title'
        message: i18n.t 'controller.game.not_enough_health.message'
        key    : 'game-ko'
        ok     : => @redirectTo 'shop'
    else if config.pay_game
      # This will save the new health locally and at distance
      user.increment('health', -1).save null,
        success: (user) -> callback?()
        error: (user, error) ->
          PopUpHelper.initialize
            title  : i18n.t 'controller.game.could_not_pay.title'
            message: i18n.t 'controller.game.could_not_pay.message'
            key    : 'game-ko'
            ok     : => @redirectTo 'home'
    else callback?()

  loadGame: (callback) =>
    GameStatHelper.reset()

    response =
      stages:
        dupa:
          questions:
            @initQuestions()

    console.log 'GAME => ', response
    @game = response
    @initPlayers()
    @loaded = yes
    callback()

  finishGame: =>
    human = @players[0]

    # Track endgames
    # AnalyticsHelper.trackPageView "EndGame - #{@i18nStageName}"

    data =
      jackpot : human.get('jackpot')
      uuid    : mediator.user.get('uuid')

    unless isNaN(human.get('jackpot'))
      GameCenter?.reportScore human.get('jackpot'), ConfigHelper.config.gamecenter.leaderboard

    @redirectToRoute "game-won", {jackpot: human.get('jackpot'), rank: human.get('rank')}

  # Load next stage
  # --------------------
  loadNextStage: =>
    return if not @loaded
    @currentStageIndex++
    stage = @stages[@currentStageIndex]
    @i18nStageName = stage.i18n_key
    @stageName = stage.name if not /duel/.test stage.name # set current stage name, skip duels (duel = stage before duel)
    @currentController?.dispose()
    @currentController = Factory.stageController stage, @players, @game.stages[stage.name]
    @currentController.start()

    # Track start stages
    # AnalyticsHelper.trackPageView @i18nStageName

  initPlayers: =>
    @players = [new Player(Parse.User.current().attributes)]

  initQuestions: =>
    _.groupBy QuestionsList, (question) ->
      question.difficulty

  dispose: ->
    @currentController?.dispose()
    super

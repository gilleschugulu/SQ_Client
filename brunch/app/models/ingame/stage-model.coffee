utils   = require 'lib/utils'
Model   = require 'models/base/model'
Bot     = require 'models/ingame/bot-model'
Factory = require 'helpers/factory-helper'

module.exports = class Stage extends Model
  playerIndex: -1
  questionIndex: -1
  failedQuestions: []
  defaults:
    questions : null
    players   : null
    config    : null
    roundCount: -1

  setConfig: (config) ->
    @set 'config', config
    @

  setQuestions: (questions) ->
    @set 'questions', (Factory.questionModel(question_data) for question_data in questions)
    @

  setPlayers: (players) ->
    throw "stage config should be set" unless @get 'config'
    players = (player.configure(@get('config').player) for player in players when not player.isEliminated())
    @set 'players', players
    @

  getAllUnusedQuestions: ->
    all_questions = []
    for question in @get('questions')
      all_questions.push question unless question.get('found')
    return all_questions

  getCurrentQuestion: ->
    all_questions = @getAllUnusedQuestions()
    return null if @questionIndex >= all_questions.length
    all_questions[@questionIndex]

  getNextQuestion: (reset = no) ->
    @questionIndex = -1 if reset
    all_questions = @getAllUnusedQuestions()
    return null if ++@questionIndex >= all_questions.length
    all_questions[@questionIndex]

  getHumanPlayer: ->
    (player for player in @get('players') when !(player instanceof Bot))?[0]

  getPlayerWithCid: (cid) ->
    (player for player in @get('players') when player.cid is cid)?[0]

  getOtherPlayers: (player) ->
    (otherPlayer for otherPlayer in @get('players') when otherPlayer.cid isnt player.cid and not otherPlayer.isEliminated())

  getNextPlayerName: ->
    players = @get 'players'
    players[(@playerIndex + 1) % players.length].get('nickname')

  getCurrentPlayer: ->
    players = @get 'players'
    player = players[@playerIndex]

  getNextPlayer: ->
    players = @get 'players'
    @playerIndex = (@playerIndex + 1) % players.length
    player = players[@playerIndex]
    player

  decreaseBotsSkill: ->
    decrease = @getConfigValue 'botsSkillDecrease'
    if decrease? and @get('roundCount') >= decrease.threshold
      player.decreaseSkill(decrease.value) for player in @get('players') when player instanceof Bot and not player.isEliminated()

  getConfigValue: (key) ->
    @get('config').stage[key]

  getQuestionType: ->
    utils.underscorize(@get('questions')[0].get('type'))

  incrementRound: ->
    c = @get('roundCount') + 1
    @set 'roundCount', c
    c

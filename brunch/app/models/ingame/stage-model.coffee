utils   = require 'lib/utils'
Model   = require 'models/base/model'
Factory = require 'helpers/factory-helper'

module.exports = class Stage extends Model
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
    q = {}

    for question_difficulty, questions_data of questions
      q[question_difficulty] = (Factory.questionModel(question_data) for question_data in questions_data.shuffle())

    @set 'questions', q
    @

  setPlayers: (players) ->
    throw "stage config should be set" unless @get 'config'
    players = (player.configure(@get('config').player) for player in players)
    @set 'players', players
    @

  getCurrentQuestion: ->
    @get('questions')[@questionIndex % @get('questions').length]

  getNextQuestion: (reset = no) ->
    @questionIndex = -1 if reset
    ++@questionIndex
    @get('questions')[@questionIndex % @get('questions').length]

  getHumanPlayer: ->
    @get('players')[0]

  getConfigValue: (key) ->
    @get('config').stage[key]

  getQuestionType: ->
    utils.underscorize(@get('questions')[0].get('type'))

  incrementRound: ->
    c = @get('roundCount') + 1
    @set 'roundCount', c
    c

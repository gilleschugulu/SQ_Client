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
    @set 'questions', (Factory.questionModel(question_data) for question_data in questions)
    @

  setPlayers: (players) ->
    throw "stage config should be set" unless @get 'config'
    players = (player.configure(@get('config').player) for player in players)
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
    ++@questionIndex
    # return null if ++@questionIndex >= all_questions.length
    all_questions[@questionIndex % all_questions.length]

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

Model = require 'models/base/model'

module.exports = class Question extends Model
  defaults:
    propositions: null
    used        : no
    masked      : no

  isCorrectAnswer: (answerId) ->
    for proposition in @get('propositions') when parseInt(proposition.id) is parseInt(answerId)
      return proposition.is_valid
    no

  getCorrectAnswer: ->
    for proposition in @get('propositions') when proposition.is_valid
      return proposition.id

  getPropositions: ->
    _.shuffle @get('propositions')

Model = require 'models/base/model'

module.exports = class Question extends Model
  defaults:
    propositions: null
    used        : no
    masked      : no

  isCorrectAnswer: (answerId) ->
    for proposition in @get('propositions')
      return proposition.is_valid if parseInt(proposition.id) is parseInt(answerId)
    no

  getPropositions: ->
    @get('propositions').shuffle()

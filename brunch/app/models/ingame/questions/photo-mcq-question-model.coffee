Question = require 'models/ingame/question-model'

module.exports = class PhotoMcqQuestion extends Question

  getWrongAnwers: (limit) ->
    (proposition for proposition in @get('propositions') when !proposition.is_valid).shuffle().slice(0, limit)

  getGoodAnwer: ->
    (proposition for proposition in @get('propositions') when proposition.is_valid)[0].text

  getPonderatedAnwers: ->
    total = 100
    offset = @get('difficulty') * 3
    min = offset + (5 - @get('difficulty')) * 10
    max = offset + (5 - @get('difficulty')) * 20 - min

    @get('propositions').sort((proposition) ->
      !proposition.is_valid
    ).map (proposition) ->
      if proposition.is_valid
        value = Math.random() * max + min
        total -= value
      else
        value = total / 3

      proposition.massOpinion = parseInt(value)
      proposition
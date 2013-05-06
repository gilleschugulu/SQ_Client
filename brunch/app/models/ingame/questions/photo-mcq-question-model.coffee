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

    player_base = Math.floor(Math.random() * max + min)
    bot_base = Math.floor((total - player_base) / 3)

    @get('propositions').sort((proposition) ->
      !proposition.is_valid
    ).map (proposition) ->
      
      if proposition.is_valid
        value = player_base
        total -= value
      else
        value = bot_base + Math.floor((Math.random() * 6 - 3))
        total -= value

      proposition.massOpinion = parseInt(value)
      proposition

    unless total is 0
      @get('propositions')[1].massOpinion = Math.round(@get('propositions')[1].massOpinion + total)

    @get('propositions')
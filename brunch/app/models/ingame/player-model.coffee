Model = require 'models/base/model'

module.exports = class Player extends Model
  defaults:
    jackpot: 0
    bonus:
      fifty_fifty: 4
      double: 1
      freeze: 20
      skip: 12
      mass: 0

  addJackpot: (someJackpot) ->
    amount = @get('jackpot') + someJackpot
    @set 'jackpot', amount

  consumeBonus: (bonus_consumed) ->
    qty = @get('bonus')[bonus_consumed]
    return false if qty <= 0
    @attributes['bonus'][bonus_consumed] = qty - 1
    true

  getBonusQuantity: (bonus) ->
    a = @get('bonus')[bonus]
    a

  getBonuses: ->
    bonuses = []
    for name, qty of @get('bonus')
      bonuses.push({
        name: name
        quantity: qty
      })

    bonuses

  # allBonus: ->
  #   [
  #     name: 'fifty-fity'
  #     quantity: @get('bonus-fifty-fity')
  #   ]

  # called before each stage to configure player for stage (set HP, skill etc)
  configure: (config) ->
    @set(config)
    @
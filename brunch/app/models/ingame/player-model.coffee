Model = require 'models/base/model'

module.exports = class Player extends Model
  defaults:
    nickname       : 'NewPlayer01'
    avatar         : null
    master         : false
    friend         : false
    friend_uuid    : null
    gender         : 'male'
    jackpot        : 10000
    hp             : 2
    duelist        : false
    eliminated     : false
    skin           : 0
    answerCount    : 0
    goodAnswerCount: 0

  initialize: ->
    super
    skin = parseInt(Math.random()*3)
    @set('skin', skin)

  decreaseHP: ->
    return if @isDead()
    value = @get('hp') - 1
    @set('hp', value)
    @die() if value is 0
    return value

  isDead: ->
    @get('hp') is 0

  die: ->
    @set('hp', 0)

  addJackpot: (someJackpot) ->
    amount = @get('jackpot') + someJackpot
    @set 'jackpot', amount

  giveJackpotToPlayer: (player) ->
    player.addJackpot @get('jackpot')
    @set 'jackpot', 0

  # called before each stage to configure player for stage (set HP, skill etc)
  configure: (config) ->
    @set(config) unless @isEliminated()
    @

  isEliminated: ->
    @get 'eliminated'

  eliminate: ->
    @set 'eliminated', yes

  isMaster: ->
    @get 'master'

  isDuelist: ->
    @get 'duelist'

  challengePlayer: (duelist) ->
    duelist.set('duelist', true)
    @set('duelist', true)
    duelist

  getGoodAnswerPercentage: ->
    return 0 if @get('answerCount') is 0
    Math.round(@get('goodAnswerCount') / @get('answerCount') * 100)

  answered: (success) ->
    @set('answerCount', @get('answerCount') + 1)
    @set('goodAnswerCount', @get('goodAnswerCount') + 1) if success

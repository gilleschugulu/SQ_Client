ranks_percentages = require('cloud/ranks_config.js').data
utils = require('cloud/utilities.js')
_ = require('underscore')

# job configured on Parse jobs to run every day (currently they dont allow to run jobs on weekly basis)
# so check first if its monday (just after midnight)

exports.task = (request, response) ->
  d = (new Date()).getUTCDay()
  # run only on modays after midnight..
  # ATTNETION !  0 = SUNDAY, parse server time is UTC => french time = UTC+2H
  # so the job is scheduled to run on SUNDAYS @22h01 UTC which is MONDAY 00h01 french time !
  if d isnt 0
    if d is 5
      return response.error('http://www.youtube.com/watch?v=kfVsfOSbJY0')
    return response.error('not a moday yet :(')

  query = new Parse.Query('User')
  query.find
    success: (results) ->
      Parse.Cloud.useMasterKey()

      # We split players in different arrays, to avoid moving twice a player
      playersPerRank = _.groupBy results, (player) ->
        player.get('rank')
      allPlayers = []

      for rank, players of playersPerRank
        players = utils.sortByScoreAndAlphabetic(players)

        playersNumber = players.length
        continue unless players.length > 0

        percents = ranks_percentages[rank - 1]
        continue unless percents

        uppedNumber = Math.ceil(playersNumber * percents.up / 100)
        downedNumber = Math.ceil(playersNumber * percents.down / 100)
        uppedIndex = uppedNumber
        downedIndex = playersNumber - downedNumber

        for user, index in players
          if index < uppedIndex
            user.increment('rank')
          else if index > downedIndex
            user.increment('rank', -1)
          user.set('score', 0).set('game_row', 0).set('life_given', [])
          allPlayers.push user

      Parse.Object.saveAll allPlayers,
        success: ->
          response.success('ok')
        error: ->
          response.error('could not save users')
    error: ->
      response.error('no users')
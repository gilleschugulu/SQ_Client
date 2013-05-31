ranks_percentages = require('cloud/ranks_percentages.js').data
utils = require('cloud/utilities.js')
_ = require('underscore')

exports.task = (request, response) ->

  query = new Parse.Query('User')
  query.find
    success: (results) ->
      Parse.Cloud.useMasterKey()

      # We split players in different arrays, to avoid moving twice a player
      playersPerRank = _.groupBy results, (player) ->
        player.get('rank')
      allPlayers = []

      for rank, players of playersPerRank
        players = utls.sortByScoreAndAlphabetic(players)

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
          user.set('score', 0). set('game_row', 0)
          allPlayers.push user

      Parse.Object.saveAll allPlayers,
        success: ->
          response.success('ok')
        error: ->
          response.error('no')
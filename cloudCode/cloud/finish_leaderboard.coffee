ranks_percentages = require('cloud/ranks_percentages.js')
_ = require('underscore')

exports.task = (request, response) ->
  increaseUsersRank = (numberToKeep, users) ->
    guys = _.first(users, numberToKeep)
    for user in guys
      user.increment('rank')
    guys

  decreaseUsersRank = (numberToKeep, users) ->
    guys = _.last(users, numberToKeep)
    for user in guys
      user.increment('rank', -1)
    guys

  query = new Parse.Query('User')
  query.descending('score')
  query.find
    success: (results) ->
      Parse.Cloud.useMasterKey()

      playersPerRank = _.groupBy results, (player) ->
        player.get('rank')

      for rank, players of playersPerRank
        playersNumber = players.length
        return unless players.length > 0

        percents = ranks_percentages[rank - 1]
        return unless percents

        if (number = Math.ceil(playersNumber * percents.up / 100)) > 0
          uppedGuys = increaseUsersRank(number, players)

        if (number = Math.ceil(playersNumber * percents.down / 100)) > 0
          downedGuys = decreaseUsersRank(number, players)

        for user in players
          user.set('score', 0).set('game_row', 0).save()

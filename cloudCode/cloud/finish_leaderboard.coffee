_ = require('underscore')

exports.task = (request, response) ->
  requestsDone = 0

  ranks_percentages = [
    up: 95
    down: 0
  ,
    up: 90
    down: 1
  ,
    up: 80
    down: 2
  ,
    up: 70
    down: 4
  ,
    up: 60
    down: 8
  ,
    up: 50
    down: 16
  ,
    up: 40
    down: 32
  ,
    up: 30
    down: 48
  ,
    up: 20
    down: 64
  ,
    up: 0
    down: 80
  ]

  increaseUsersRank = (numberToKeep, users) ->
    guys = _.first(users, numberToKeep)
    for user in guys
      user.set('score', 0).increment('rank').save()
    guys

  decreaseUsersRank = (numberToKeep, users) ->
    guys = _.last(users, numberToKeep)
    for user in guys
      user.set('score', 0).increment('rank', -1).save()
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

        players = _.difference(players, uppedGuys)
        if (number = Math.ceil(playersNumber * percents.down / 100)) > 0
          downedGuys = increaseUsersRank(number, players)

        players = _.difference(players, downedGuys)
        for user in players
          user.set('score', 0).save()

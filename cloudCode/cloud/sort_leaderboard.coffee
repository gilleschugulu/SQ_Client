_ = require("underscore")

exports.task = (request, response) ->
  userRank = request.params.rank
  userId = request.params.userId
  query = new Parse.Query('User')
  query.equalTo('rank', userRank)
  query.descending('score')

  query.find
    success: (results) ->
      playerIndex = 0

      return response.success({players: [], total: 0}) if results.length is 0

      _.find results, (user) ->
        playerIndex++
        user.id is userId

      data =
        total: results.length

      if playerIndex < 8
        data.players = fetchUsers(results, 0, 9)
        response.success(data)
      else if playerIndex > results.length - 5
        data.players = fetchUsers(results, 0, 2).concat fetchUsers(results, results.length - 7, results.length - 1)
        response.success(data)
      else
        data.players = (fetchUsers(results, 0, 2).concat fetchUsers(results, playerIndex - 3, playerIndex + 3))
        response.success(data)
    error: (results) ->
      response.error('toto')

  fetchUsers = (users, minIndex, maxIndex) ->
    players = (for user, index in users
      {
        username: user.get('username')
        object_id: user.id
        fb_id: user.get('fb_id')
        score: user.get('score')
        rank: userRank
        position: index + 1
      })[minIndex..maxIndex]

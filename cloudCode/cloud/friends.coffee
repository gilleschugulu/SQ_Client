utils = require('cloud/utilities.js')

exports.task = (request, response) ->
  playerId = request.params.userId
  friendsId = request.params.friendsId

  playerQuery = new Parse.Query('User')
  playerQuery.get playerId,
    success: (player) ->
      query = new Parse.Query('User')
      query.containedIn('fb_id', friendsId)

      query.find
        success: (results) ->
          results.push player

          results = utils.sortByScoreAndAlphabetic(results)

          players = (for user, index in results
            {
              friend: true
              fb_id: user.get('fb_id')
              username: user.get('username')
              object_id: user.id
              score: user.get('score') | 0,
              rank: user.get('rank') | 0
              position: index + 1
            }
          )

          response.success(players)
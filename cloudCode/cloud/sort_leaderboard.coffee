exports.task = (request, response) ->
  userRank = request.params.rank
  userId = request.params.userId

  query = new Parse.Query('User')
  query.equalTo('rank', userRank)
  query.descending('score')

  query.find
    success: (results) ->
      i = 0
      while results[i].id isnt userId
        i++
      if i < 8
        response.success(fetchUsers(results, 0, 9))
      else if i > results.length-5
        response.success(fetchUsers(results, results.length-10, results.length-1))
      else
        board = (fetchUsers(results, 0, 2).concat fetchUsers(results, i-3, i+3))
        response.success(board)
    error: (results) ->
      response.error('toto')

  fetchUsers= (users, min, max) ->
    board = (for user, i in users
      {
        username: user.get('username')
        object_id: user.id
        fb_id: user.get('fb_id')
        score: user.get('score')
        rank: i+1
      })[min..max]


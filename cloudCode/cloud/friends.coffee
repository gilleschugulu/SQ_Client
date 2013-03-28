exports.task = (request, response) ->
  friendsId = request.params.friendsId

  query = new Parse.Query('User')
  query.containedIn('fb_id', friendsId)

  query.find
    success: (results) ->
      response.success(for user in results
        {
          friend: true
          fb_id: user.get('fb_id')
          username: user.get('username')
          object_id: user.id
          score: user.get('score')
        }
      )
exports.task = (request, response) ->
  query = new Parse.Query('User').equalTo('fb_id', request.params.friendsId.toString())
  query.find
    success: (results) ->
      Parse.Cloud.useMasterKey()
      results[0].increment('health', 1).save()
      response.success {id:results[0].get('fb_id')}
    error: (results) ->
      response.error results

exports.task = (request, response) ->
  column = request.params.column
  value = request.params.value
  query = new Parse.Query('User')
  query.find
    success: (results) ->
      Parse.Cloud.useMasterKey()

      # Not calling response.success to avoid issue with asynchronism
      for user in results
        user.set(column, value).save()
    error: (results) ->
      response.error()


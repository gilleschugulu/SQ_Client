utils = require('cloud/utilities.js')
_ = require("underscore")

exports.task = (request, response) ->
  friendsId = request.params.friendsId

  query = new Parse.Query('User')
  query.containedIn 'fb_id', friendsId
  query.find
    success: (results) ->

      results = _.uniq results, no, (user) -> user.get('fb_id')
      results = utils.sortByScoreAndAlphabetic(results)

      response.success (for user, index in results
        {
          fb_id    : user.get('fb_id')
          username : user.get('username')
          score    : user.get('score') | 0
          rank     : user.get('rank') | 0
          position : index + 1
        }
      )

    error: -> response.error.apply null, arguments
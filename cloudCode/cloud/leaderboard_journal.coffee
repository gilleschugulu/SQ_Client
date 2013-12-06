# This task should return a number of players (given by request.params.size)
# An array of offsets is set.
# For each entry, we will make a request to seek the player after the given offset

# By default, we will take the first user (offset 0)
# If there is at least 2 users, we add an offset equal to number of users - 1. So last user.
# It there is more than 2 users, we add people at regular interval

exports.task = (request, response) ->
  Parse.Cloud.httpRequest
    method: 'GET'
    url: "http://sport-quiz.herokuapp.com/parse/journal_leaderboard/#{request.params.size}"
    error: -> response.error.apply null, arguments
    success: (res) -> response.success res.data


  # tasks   = request.params.size
  # players = []

  # getQuery = ->
  #   (new Parse.Query('User')).greaterThan('score', 0)

  # taskDone = (max) ->
  #   if --tasks is 0
  #     # Sort of uniqueness
  #     players.slice(0, max)

  #     response.success(for player in players
  #       {
  #         position : player.position | 0
  #         fb_id    : player.get('fb_id')
  #         username : player.get('username')
  #         object_id: player.id
  #         score    : player.get('score') | 0
  #       })

  # fetchUser = (offset, max) ->
  #   getQuery().descending('score').skip(offset).first
  #     success: (user) ->
  #       if user
  #         user.position = offset + 1
  #         players.push user
  #       taskDone max
  #     error: ->
  #       taskDone max


  # getQuery().count
  #   success: (number) ->
  #     count = request.params.size
  #     offsets = [0]
  #     if count > 1
  #       if count > 2
  #         step = Math.floor(number / (count - 1))
  #         offsets.push((i + 1) * step) for i in [0..(count - 2)]
  #       offsets.push(number - 1)
  #     fetchUser(offset, number) for offset in offsets
  #   error : (obj, error) ->
  #     response.error error, "could not count"

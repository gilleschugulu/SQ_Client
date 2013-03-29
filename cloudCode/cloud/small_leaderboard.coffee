exports.task = (request, response) ->
  tasks   = request.params.size
  players = []

  getQuery = ->
    (new Parse.Query('User')).greaterThan('score', 0)

  taskDone = (max) ->
    if --tasks < 1
      # Sort of uniqueness
      players.slice(0, max)

      response.success(for player in players
        {
          position : player.position | 0
          fb_id    : player.get('fb_id')
          username : player.get('username')
          object_id: player.id
          score    : player.get('score') | 0
        })

  fetchUser = (offset, max) ->
    getQuery().descending('score').skip(offset).first
      success: (user) ->
        if user
          user.position = offset + 1
          players.push user
        taskDone max
      error: ->
        taskDone max


  getQuery().count
    success: (number) ->
      count = request.params.size
      offsets = [0]
      if count > 1
        if count > 2
          step = Math.floor(number / (count - 1))
          offsets.push((i + 1) * step) for i in [0..(count - 2)]
        offsets.push(number - 1)
      fetchUser(offset, number) for offset in offsets
    error : (obj, error) ->
      response.error error, "could not count"

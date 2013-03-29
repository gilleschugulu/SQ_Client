exports.task = (request, response) ->
  tasks   = 3
  players = []

  taskDone = ->
    if --tasks < 1
      # Sort of uniqueness
      players.slice(0, 3)

      response.success(for player in players
        {
          position : player.position | 0
          fb_id    : player.get('fb_id')
          username : player.get('username')
          object_id: player.id
          score    : player.get('score') | 0
        })

  fetchUser = (offset) ->
    (new Parse.Query('User')).descending('score').notEqualTo('score', 0).skip(offset).first
      success: (user) ->
        if user
          user.position = offset + 1
          players.push user
        taskDone()
      error: ->
        taskDone()


  (new Parse.Query('User')).notEqualTo('score', 0).count
    success: (number) ->
      fetchUser(offset) for offset in [0, Math.floor(number / 2), number - 1]

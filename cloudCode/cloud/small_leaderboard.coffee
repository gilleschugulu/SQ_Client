exports.task = (request, response) ->
  friendsId = request.params.friendsId

  players = []
  # playersId = []

  (new Parse.Query('User')).count
    success: (number) ->
      console.log number

      (new Parse.Query('User')).descending('score').notEqualTo('score', 0).first
        success: (best_user) ->
          console.log best_user
          if best_user
            best_user.position = 1
            players.push best_user
          offset = Math.ceil(number / 2)
          (new Parse.Query('User')).descending('score').notEqualTo('score', 0).skip(offset).first
            success: (mid_user) ->
              console.log mid_user
              if mid_user
                mid_user.position = offset
                players.push mid_user

              (new Parse.Query('User')).descending('score').notEqualTo('score', 0).skip(number - 1).first
                success: (worst_user) ->
                  console.log worst_user
                  if worst_user
                    worst_user.position = number
                    players.push worst_user

                  # Sort of uniqueness
                  players.slice(0, number)

                  console.log('players?')
                  console.log players

                  response.success(for player in players
                    {
                      position : player.position | 0
                      fb_id    : player.get('fb_id')
                      username : player.get('username')
                      object_id: player.id
                      score    : player.get('score') | 0
                    })

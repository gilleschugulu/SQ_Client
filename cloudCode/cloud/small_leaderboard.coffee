exports.task = (request, response) ->
  friendsId = request.params.friendsId

  players = []
  # playersId = []

  (new Parse.Query('User')).count
    success: (number) ->
      console.log number

      (new Parse.Query('User')).first
        success: (best_user) ->
          console.log best_user
          players.push best_user if best_user
          (new Parse.Query('User')).skip(number / 2).first
            success: (mid_user) ->
              console.log mid_user
              players.push mid_user if mid_user

              (new Parse.Query('User')).skip(number - 1).first
                success: (worst_user) ->
                  console.log worst_user
                  players.push worst_user if worst_user

                  # Sort of uniqueness
                  players.slice(0, number)

                  console.log('players?')
                  console.log players

                  response.success(for player in players
                    {
                      fb_id: player.get('fb_id')
                      username: player.get('username')
                      object_id: player.id
                      score: player.get('score') | 0
                    })

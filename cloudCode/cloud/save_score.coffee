exports.task = (request, response) ->
  player_id = request.params.player_id

  query = new Parse.Query('GameScore')
  query.equalTo('player_id', player_id)
  query.first
    success: (game_score) ->
      Parse.Cloud.useMasterKey()

      unless game_score
        game_score = new Parse.Object('GameScore')
        game_score.set('player_id', player_id)

      game_score.set('score', request.params.score)
      game_score.save()
      response.success()

    error: (results) ->
      response.error()
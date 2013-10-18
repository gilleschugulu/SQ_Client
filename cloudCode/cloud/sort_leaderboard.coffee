ranks_percentages = require('cloud/ranks_percentages.js').data

utils = require('cloud/utilities.js')
_ = require("underscore")

exports.task = (request, response) ->
  userRank = request.params.rank
  userId = request.params.userId
  query = new Parse.Query('User')
  query.equalTo('rank', userRank)

  query.find
    error: -> response.error.apply null, arguments
    success: (results) ->
      return response.success({players: [], total: 0}) if results.length is 0

      # Sort users by score AND username
      results = utils.sortByScoreAndAlphabetic(results)

      # Calculate player position. Not perfect way to do it
      playerIndex = 0
      _.find results, (user) ->
        if !(res = user.id is userId)
          playerIndex++
        res
        

      # Count number of players
      playersNumber = results.length
      return unless results.length > 0

      # Get the correct rank percentage
      percents = ranks_percentages[userRank - 1]
      return unless percents

      indexOfLastUpping = Math.ceil(playersNumber * percents.up / 100)
      indexOfFirstDowning = playersNumber - Math.ceil(playersNumber * percents.down / 100)

      # TODO : Comment !

      ranges =
        up: []
        stay: []
        down: []

      # Up people
      if indexOfLastUpping > 9
        ranges.up.push [0, 9]
        ranges.up.push [indexOfLastUpping]
      else if indexOfLastUpping > 0
        ranges.up.push [0, indexOfLastUpping]

      # Stay people
      ranges.stay.push [indexOfLastUpping + 1]
      ranges.stay.push [indexOfFirstDowning - 1]
      # Down people
      ranges.down.push [indexOfFirstDowning]
      ranges.down.push [playersNumber - 1]

      if playerIndex < indexOfLastUpping
        ranges.up.push [playerIndex]
      else if playerIndex > indexOfFirstDowning
        ranges.down.push [playerIndex]
      else
        ranges.stay.push [playerIndex]

      players = fetchUsersRanges(results, ranges)

      response.success({players: players, total: playersNumber})

  fetchUsersRanges = (users, blocks) ->
    players = []

    for range_name, ranges of blocks
      for range in ranges
        if isNaN(range)
          players.push(fetchAndParseUsers(users, range, range_name))
        else
          players.push( fetchAndParseUser(users, range, range_name))

    players = _.flatten(players, true)
    players = _.compact(players)
    players = _.uniq players, no, (player) ->
      player.position
    players = players.sort (p1, p2) ->
      p1.position - p2.position

    players

  fetchAndParseUsers = (users, range, range_name) ->
    for user, index in users[range[0]..range[1]]
      continue unless user
      user = parseUser(user, range[0] + index, range_name)
      user

  fetchAndParseUser = (users, range, range_name) ->
    index = range[0]
    user = users[index]
    return unless user
    user = parseUser(user, index, range_name)
    user

  parseUser = (user, position, range_name) ->
    {
      username: user.get('username')
      object_id: user.id
      fb_id: user.get('fb_id')
      score: user.get('score')
      rank: userRank
      position: parseInt(position) + 1
      range_name: range_name
    }
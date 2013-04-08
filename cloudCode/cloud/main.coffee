Parse.Cloud.define 'getFriendsScore', (request, response) ->
  require('cloud/friends.js').task request, response

Parse.Cloud.define 'sortLeaderboard', (request, response) ->
  require('cloud/sort_leaderboard.js').task request, response

Parse.Cloud.define 'smallLeaderboard', (request, response) ->
  require('cloud/small_leaderboard.js').task request, response

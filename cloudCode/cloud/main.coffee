Parse.Cloud.define 'getFriendsScore', (request, response) ->
  require('cloud/friends.js').task request, response

parse.cloud.define 'sortleaderboard', (request, response) ->
  require('cloud/sort_leaderboard.js').task request, response
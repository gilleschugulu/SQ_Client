Parse.Cloud.define 'getFriendsScore', (request, response) ->
  require('cloud/friends.js').task request, response

Parse.Cloud.define 'getAllScore', (request, response) ->
  require('cloud/sort_leaderboard.js').task request, response

Parse.Cloud.define 'smallLeaderboard', (request, response) ->
  require('cloud/small_leaderboard.js').task request, response

Parse.Cloud.define 'giveLife', (request, response) ->
  require('cloud/giveLife.js').task request, response

Parse.Cloud.define 'clean', (request, response) ->
  require('cloud/clean.js').task request, response

Parse.Cloud.define 'saveScore', (request, response) ->
  require('cloud/save_score.js').task request, response
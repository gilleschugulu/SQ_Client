// Generated by CoffeeScript 1.6.2
Parse.Cloud.define('getFriendsScore', function(request, response) {
  return require('cloud/friends.js').task(request, response);
});

Parse.Cloud.define('getAllScore', function(request, response) {
  return require('cloud/sort_leaderboard.js').task(request, response);
});

Parse.Cloud.define('smallLeaderboard', function(request, response) {
  return require('cloud/small_leaderboard.js').task(request, response);
});

Parse.Cloud.define('giveLife', function(request, response) {
  return require('cloud/giveLife.js').task(request, response);
});

Parse.Cloud.define('clean', function(request, response) {
  return require('cloud/clean.js').task(request, response);
});
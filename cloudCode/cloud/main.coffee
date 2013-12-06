functions = [
	'shop_config'
	'leaderboard_friends'
	'leaderboard'
	'leaderboard_journal'
	'give_life'
	'ranks'
	# 'clean'
]

jobs = [
	'finish_tournament'
]

Parse.Cloud.define f, (require("cloud/#{f}.js").task) for f in functions
Parse.Cloud.job j, (require("cloud/#{j}.js").task) for j in jobs

Parse.Cloud.afterSave Parse.User, (request) ->
  user = request.object.attributes
  user.parse_identifier = request.object.id
  Parse.Cloud.httpRequest
    method: 'POST'
    url: "http://sport-quiz.herokuapp.com/parse"
    body:
      user: JSON.stringify(user)

Parse.Cloud.afterDelete Parse.User, (request) ->
  Parse.Cloud.httpRequest
    method: 'DELETE'
    url: "http://sport-quiz.herokuapp.com/parse/#{request.object.id}"

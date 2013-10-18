functions = [
	'shop_config'
	'leaderboard_friends'
	'leaderboard'
	'leaderboard_journal'
	'give_life'
	'save_score'
	'ranks'
	'clean'
]

jobs = [
	'finish_tournament'
]

Parse.Cloud.define f, (require("cloud/#{f}.js").task) for f in functions
Parse.Cloud.job j, (require("cloud/#{j}.js").task) for j in jobs

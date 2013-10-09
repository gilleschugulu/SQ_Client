routeList = {
  outgame: [
    ['', 'login#index']
    ['home', 'home#index']
    ['more-games', 'more-games#index']
    ['profile', 'profile#index']
    ['invite', 'invitation#index']
    ['options', 'options#index']
    ['shop', 'shop#index']
    ['tutorial', 'tutorial#index']
    ['hall-of-fame/:nextRoute', 'hall-of-fame#index', name: 'hall-of-fame']
    ['credits', 'credits#index']
  ]
  ingame: [
    ['game', 'game#index']
    ['game-won/:jackpot/:rank', 'game-over#won', name: 'game-won']
    ['game-lost/:jackpot/:rank', 'game-over#lost', name: 'game-lost']
  ]
}
module.exports = (match) ->
  for namespace, routes of routeList
    for route in routes
      route[1] = "#{namespace}/#{route[1]}"
      match.apply null, route

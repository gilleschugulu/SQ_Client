routeList = {
  outgame: [
    ['', 'login#index']
    ['home', 'home#index']
    ['more-games', 'more-games#index']
    ['masters', 'hall-of-fame#index']
    ['profile', 'profile#index']
    ['invite', 'invitation#index']
    ['options', 'options#index']
    ['shop', 'shop#index']
  ]
  ingame: [
    ['game', 'game#index']
    ['game-won/:jackpot/:rank/:reward', 'game-over#won', name: 'game-won']
    ['game-lost/:jackpot/:rank', 'game-over#lost', name: 'game-lost']
  ]
}
module.exports = (match) ->
  for namespace, routes of routeList
    for route in routes
      route[1] = "#{namespace}/#{route[1]}"
      match.apply null, route

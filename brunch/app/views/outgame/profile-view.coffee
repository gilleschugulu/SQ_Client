View = require 'views/base/view'
template = require 'views/templates/outgame/profile'
mediator = require 'mediator'

module.exports = class ProfileView extends View
  template: template
  className: 'profile-page'
  container: '#page-container'
  autoRender: true

  getTemplateData: ->
    mediator.user.getAttributes()

  updateStats: (stats) ->
    $('.block.played .score-container', @$el).text stats.games_played
    $('.block.won .score-container', @$el).text stats.games_won
    $('.block.best-score .score-container', @$el).text stats.rank_max
    $('.block.best-cash .score-container', @$el).text @niceNumber(stats.jackpot_max)
    $('.block.stars .score-container', @$el).text stats.mystery_star_done

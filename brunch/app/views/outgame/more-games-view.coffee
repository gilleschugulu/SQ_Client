View = require 'views/base/view'
template = require 'views/templates/outgame/more-games'

module.exports = class MoreGamesView extends View
  autoRender: yes
  className: 'more-games'
  container: '#page-container'
  template: template

  setContent: (htmlContent) ->
    $('#more-games-content', @$el).html htmlContent
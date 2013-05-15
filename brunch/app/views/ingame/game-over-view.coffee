template = require 'views/templates/ingame/game-over'
View = require 'views/base/view'

module.exports = class GameOverView extends View
  autoRender: yes
  className: 'game-over fixedSize'
  container: '#page-container'
  template: template
  iphone5Class: 'game-over-page-568h'

  getTemplateData: ->
    @options
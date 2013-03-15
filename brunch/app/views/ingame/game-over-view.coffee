template = require 'views/templates/ingame/game-over'
View = require 'views/base/view'

module.exports = class GameOverView extends View
  autoRender: yes
  className: 'game-over'
  container: '#page-container'
  template: template

  getTemplateData: ->
    @options
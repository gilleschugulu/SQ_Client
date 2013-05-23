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

  bonusAppear: ->
    bonusDiv = $('.best-jackpot .bonus', @$el)

    bonusDiv.removeClass('hide').addClass('animated fadeInRight').one 'webkitAnimationEnd', ->
      bonusDiv.removeClass('animated fadeInRight').addClass('animated wiggle').one 'webkitAnimationEnd', ->
        bonusDiv.removeClass('animated wiggle')

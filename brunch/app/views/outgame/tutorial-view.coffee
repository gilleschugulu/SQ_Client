View     = require 'views/base/view'
template = require 'views/templates/outgame/tutorial'

module.exports = class TutorialView extends View
  template  : template
  className : 'tutorial'
  autoRender: yes
  container : '#page-container'

  getTemplateData: ->
    @options

  changeScreen: (screenNumber) ->
    $('#pagination li').removeClass('current').eq(screenNumber - 1).addClass('current')
    $('.screen', @$el).css('background-image', "url(images/tutorial/tutoriel_#{screenNumber}.jpg)")
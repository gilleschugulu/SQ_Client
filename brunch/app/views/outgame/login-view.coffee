View = require 'views/base/view'
template = require 'views/templates/outgame/login'

module.exports = class LoginView extends View
  template: template
  autoRender: yes
  className: 'login-page-container'
  container: '#page-container'
  animInterval: {}
  animInterval2: {}

  animateFacebook: ->
    @animInterval = setInterval =>
      $('.facebook-login').addClass('animated tada').one 'webkitAnimationEnd', ->
        $(this).removeClass('animated tada')
    , 2500
    @animInterval2 = setInterval =>
      $('.equipe-login').addClass('animated tada').one 'webkitAnimationEnd', ->
        $(this).removeClass('animated tada')
    , 3000

  openForms: ->
    # $('#equipe-forms', @$el).addClass 'shown'
    $('#flipper', @$el).addClass 'flipped'

  closeForms: ->
    # $('#equipe-forms', @$el).removeClass 'shown'
    $('#flipper', @$el).removeClass 'flipped'
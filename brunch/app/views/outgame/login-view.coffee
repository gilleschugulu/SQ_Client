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
    # @animInterval2 = setInterval =>
    #   $('.fb-reward, .facebook-login').addClass('animated tada').one 'webkitAnimationEnd', ->
    #     $(this).removeClass('animated tada')
    # , 2500
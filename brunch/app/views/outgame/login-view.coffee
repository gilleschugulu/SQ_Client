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

  showMailLoginView: (callback) ->
    clearInterval @animInterval
    $('.btn-container, .fb-reward, .or', @$el).addClass('animated fadeOut')
    $('.btn-container', @$el).one 'webkitAnimationEnd', =>
      $('.btn-container', @$el).remove()
      $('form#login', @$el).addClass 'animated flipInX'

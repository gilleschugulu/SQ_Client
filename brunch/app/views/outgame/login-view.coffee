View = require 'views/base/view'
template = require 'views/templates/outgame/login'

module.exports = class LoginView extends View
  template: template
  autoRender: yes
  className: 'login-page-container'
  container: '#page-container'
  animInterval: {}
  animInterval2: {}

  getTemplateData: ->
    @options

  animateFacebook: ->
    @animInterval = setInterval =>
      $('.facebook-login').addClass('animated tada').one 'webkitAnimationEnd', ->
        $(this).removeClass('animated tada')
    , 2500
    @animInterval2 = setInterval =>
      $('.equipe-login').addClass('animated tada').one 'webkitAnimationEnd', ->
        $(this).removeClass('animated tada')
    , 3000

  openTempForm: ->
    $('#equipe-forms').hide()
    $('#temp-form').show()

    $('#flipper', @$el).addClass 'flipped'

  openForms: ->
    # $('#equipe-forms', @$el).addClass 'shown'
    $('#equipe-forms').show()
    $('#temp-form').hide()

    $('#flipper', @$el).addClass 'flipped'

  closeForms: ->
    # $('#equipe-forms', @$el).removeClass 'shown'
    $('#flipper', @$el).removeClass 'flipped'
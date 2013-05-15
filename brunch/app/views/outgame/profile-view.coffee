View = require 'views/base/view'
template = require 'views/templates/outgame/profile'
mediator = require 'mediator'

module.exports = class ProfileView extends View
  autoRender: true
  className: 'profile-page fixedSize'
  container: '#page-container'
  template: template
  iphone5Class: 'profile-page-568h'

  getTemplateData: ->
    @options

  activateFbButton: ->
    $('.facebook-link').addClass('done')
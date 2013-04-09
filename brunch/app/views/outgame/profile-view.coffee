View = require 'views/base/view'
template = require 'views/templates/outgame/profile'
mediator = require 'mediator'

module.exports = class ProfileView extends View
  template: template
  className: 'profile-page'
  container: '#page-container'
  autoRender: true

  getTemplateData: ->
    @options
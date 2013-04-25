View     = require 'views/base/view'
template = require 'views/templates/outgame/credits'

module.exports = class CreditsView extends View
  template  : template
  className : 'credits'
  autoRender: yes
  container : '#page-container'

  getTemplateData: ->
    @options

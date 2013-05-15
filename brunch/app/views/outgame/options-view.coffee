View = require 'views/base/view'
template = require 'views/templates/outgame/options'

module.exports = class OptionsView extends View
  template: template
  autoRender: yes
  className: 'options-container fixedSize'
  container: '#page-container'
  iphone5Class: 'options-page-568h'

  getTemplateData: ->
    @options.templateData

  toggleButton: (buttonId) ->
    $('#' + buttonId).toggleClass 'off'

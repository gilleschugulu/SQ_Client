template  = require 'views/templates/outgame/home'
View      = require 'views/base/view'
I18n      = require 'lib/i18n'

module.exports = class HomePageView extends View
  autoRender: yes
  className: 'home-page'
  container: '#page-container'
  template: template

  getTemplateData: ->
    @options

  toggleJournal: ->
    @subview('journal').toggle()

  addJournalView: (journalView) ->
    @subview 'journal', journalView
    @subview('journal').render().toggle()

  setJournalMessage: (key) ->
    $('#touch-me').text(I18n.t('controller.home.touch_me.' + key))
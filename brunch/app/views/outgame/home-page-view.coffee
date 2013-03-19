template = require 'views/templates/outgame/home'
View = require 'views/base/view'

module.exports = class HomePageView extends View
  autoRender: yes
  className: 'home-page'
  container: '#page-container'
  template: template

  getTemplateData: ->
    @options

  updateCountDown: (days, hours, minutes) ->
    $('#days', @$el).text (if days < 10 then '0' + days else days)
    $('#hours', @$el).text (if hours < 10 then '0' + hours else hours)
    $('#minutes', @$el).text (if minutes < 10 then '0' + minutes else minutes)

  toggleJournal: ->
    journalEl = $('.journal-container', @$el)
    journalEl.toggleClass('hiddened').toggleClass('shown')
    # if journalEl.hasClass('hidden')
      # animate pull out
    # else
      # animate pull out
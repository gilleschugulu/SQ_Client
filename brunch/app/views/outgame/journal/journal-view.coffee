View = require 'views/base/view'

module.exports = class JournalView extends View
  autoRender: yes
  className: 'journal-container shown'
  container: '.home-page'

  getTemplateData: ->
    @options.date = @getDate()
    @options

  getDate: ->
    date = new Date()
    d = if date.getDate() < 10 then '0' + date.getDate() else date.getDate()
    d += '/'
    d += if date.getMonth() < 9 then '0' + (date.getMonth() + 1) else (date.getMonth() + 1)
    d += '/' + (date.getYear() % 100)
    d

  toggle: ->
    @$el.toggleClass('hiddened').toggleClass('shown')
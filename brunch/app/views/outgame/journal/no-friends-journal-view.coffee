template    = require 'views/templates/outgame/journal/no-friends-journal'
JournalView = require 'views/outgame/journal/journal-view'

module.exports = class NoFriendsJournalView extends JournalView
  template: template
  interval: null

  constructor: (options) ->
    @className += ' no-friends'
    super

  initialize: ->
    s = super
    @interval = setInterval =>
      cd = @calculateDateCount()
      @setCountDown cd.days, cd.hours, cd.minutes
    , 1000
    s

  setCountDown: (days, hours, minutes) ->
    $('#days', @$el).text (if days < 10 then '0' + days else days)
    $('#hours', @$el).text (if hours < 10 then '0' + hours else hours)
    $('#minutes', @$el).text (if minutes < 10 then '0' + minutes else minutes)

  calculateDateCount: ->
    today = new Date()
    msPerDay = 24 * 60 * 60 * 1000
    timeLeft = (@options.targetDate.getTime() - today.getTime())
    e_daysLeft = timeLeft / msPerDay
    daysLeft = Math.floor(e_daysLeft)
    yearsLeft = 0
    if daysLeft > 365
      yearsLeft = Math.floor(daysLeft / 365)
      daysLeft = daysLeft % 365
    e_hrsLeft = (e_daysLeft - daysLeft) * 24
    hrsLeft = Math.floor(e_hrsLeft)
    minsLeft = Math.floor((e_hrsLeft - hrsLeft) * 60)
    {
      days   : daysLeft
      hours  : hrsLeft
      minutes: minsLeft
    }

  dispose: ->
    clearInterval @interval if @interval?
    super
template    = require 'views/templates/outgame/journal/two-friends-journal'
JournalView = require 'views/outgame/journal/journal-view'

module.exports = class TwoFriendsJournalView extends JournalView
  template: template

  constructor: (options) ->
    @className += ' two-friends'
    super

  getTemplateData: ->
    data = super
    medals = ['gold', 'silver', 'bronze']
    for participant, i in data.participants
      data.participants[i].rank  = i + 1
      data.participants[i].medal = medals[i]
    data
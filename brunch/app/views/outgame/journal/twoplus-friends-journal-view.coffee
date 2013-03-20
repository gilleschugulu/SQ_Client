template    = require 'views/templates/outgame/journal/twoplus-friends-journal'
JournalView = require 'views/outgame/journal/journal-view'

module.exports = class TwoplusFriendsJournalView extends JournalView
  template: template

  constructor: (options) ->
    @className += ' twoplus-friends'
    super

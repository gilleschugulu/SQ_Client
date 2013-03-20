template    = require 'views/templates/outgame/journal/two-friends-journal'
JournalView = require 'views/outgame/journal/journal-view'

module.exports = class TwoFriendsJournalView extends JournalView
  template: template

  constructor: (options) ->
    @className += ' two-friends'
    super

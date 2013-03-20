template = require 'views/templates/outgame/journal/one-friend-journal'
JournalView = require 'views/outgame/journal/journal-view'

module.exports = class OneFriendJournalView extends JournalView
  template: template

  constructor: (options) ->
    @className += ' one-friend'
    super

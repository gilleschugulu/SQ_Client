Controller                = require 'controllers/base/controller'
HomePageView              = require 'views/outgame/home-page-view'
mediator                  = require 'mediator'
i18n                      = require 'lib/i18n'
FacebookHelper            = require 'helpers/facebook-helper'
AnalyticsHelper           = require 'helpers/analytics-helper'
NoFriendsJournalView      = require 'views/outgame/journal/no-friends-journal-view'
OneFriendJournalView      = require 'views/outgame/journal/one-friend-journal-view'
TwoFriendsJournalView     = require 'views/outgame/journal/two-friends-journal-view'
TwoplusFriendsJournalView = require 'views/outgame/journal/twoplus-friends-journal-view'

module.exports = class HomeController extends Controller
  historyURL: 'home'
  title: 'Home'

  index: ->
    PushNotifications?.unblock() # display any queued notifications
    @loadView 'home'
    , =>
      user = Parse.User.current()
      new HomePageView {hearts: user.get('health'), credits: user.get('credits')}
    , (view) =>
      if mediator.justLaunched and ChartBoost?
        setTimeout =>
          # Track event
          AnalyticsHelper.trackEvent 'Splash', "ChartBoost Splash"
          ChartBoost.showInterstitial (response) =>
            @viewLoaded view
        , 1000
      else
        @viewLoaded view
      mediator.setJustLaunched no
    , {viewTransition: yes, music: 'outgame'}

  viewLoaded: (view) =>
    navigator.splashscreen.hide() if navigator?.splashscreen?.hide?
    @view?.setJournalMessage('loading')

    FacebookHelper.getFriends (friends) =>
      @getJournalView friends, =>
        @view?.setJournalMessage('touch')

      # All these links are present on the journal
      @view.delegate 'click', '#equipe-btn', =>
        @view.toggleJournal()
      @view.delegate 'click', '#invite-btn', @onClickFacebook
      @view.delegate 'click', '#hall-of-fame', =>
        @view.dim => @redirectTo 'hall-of-fame'

      @view.delegate 'click', '#game-link', =>
        @view.dim => @redirectTo 'game'
    , =>
      # Error callback, if facebook fail. Nothing to display. Retry ?
      @view?.setJournalMessage('error')


  onClickFacebook: =>
    FacebookHelper.friendRequest i18n.t('controller.home.facebook_invite_message')

  getJournalView: (friends, callback) ->
    switch friends.length
      when 0 then @getSmallLeaderboard callback, @getNoFriendsJournalView
      when 1 then @getFriendsScore friends, callback, @getOneFriendJournalView
      when 2 then @getFriendsScore friends, callback, @getTwoFriendsJournalView
      else        @getFriendsScore friends, callback, @getTwoplusFriendsJournalView

  getNoFriendsJournalView: (people) ->
    targetDate = new Date()
    targetDate.setHours(0)
    targetDate.setMinutes(0)
    targetDate.setSeconds(0)
    targetDate.setDate(targetDate.getDate() - targetDate.getDay() + 7)

    options =
      targetDate  : targetDate
      username    : Parse.User.current().get('username')
      fb_id       : Parse.User.current().get('fb_id')
      participants: people
    console.log people
    return new NoFriendsJournalView options


  getFriendsScore: (friends, callback, journalView) ->
    friendsId = _.pluck(friends, 'id')

    Parse.Cloud.run 'getFriendsScore', { friendsId: friendsId },
      success: (players) =>
        players.push Parse.User.current().attributes
        players = players.sort (f1, f2) ->
          f2.score - f1.score
        @view.addJournalView journalView(players)
        callback()
      error: (error) ->
        console.log 'ERROR : ', error

  getSmallLeaderboard: (journalView, callback) ->
    Parse.Cloud.run 'smallLeaderboard', {size : 3},
      success: (players) =>
        players = players.sort (f1, f2) ->
          f2.score - f1.score
        @view.addJournalView journalView(players)
        callback()
      error: (error) ->
        console.log 'ERROR : ', error

  getOneFriendJournalView: (players) ->
    options =
      winner: players[0].username
      loser: players[1].username
      participants: players

    new OneFriendJournalView options

  getTwoFriendsJournalView: (players) ->
    options =
      master: players[0].username
      participants: players

    return new TwoFriendsJournalView options

  getTwoplusFriendsJournalView: (players) ->
    rank = _.indexOf(players, Parse.User.current().attributes) + 1
    name = Parse.User.current().get('username')
    if rank < 4
      title = i18n.t "controller.home.journal.twoplus.rank_#{rank}", name
    else
      title = i18n.t "controller.home.journal.twoplus.rank_n", name, rank, null
    options =
      title       : title
      participants: players

    new TwoplusFriendsJournalView options

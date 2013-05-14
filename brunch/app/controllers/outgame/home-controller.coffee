Controller                = require 'controllers/base/controller'
mediator                  = require 'mediator'
i18n                      = require 'lib/i18n'
FacebookHelper            = require 'helpers/facebook-helper'
AnalyticsHelper           = require 'helpers/analytics-helper'
popUp                     = require 'helpers/pop-up-helper'
HomePageView              = require 'views/outgame/home-page-view'
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

    @view.delegate 'click', '#game-link', =>
      user = Parse.User.current()
      if user.get('health') > 0
        @view.dim => @redirectTo 'game'
      else
        popUp.initialize {template: 'no-more-coins'}

    FacebookHelper.getFriends (friends) =>
      @getJournalView friends, =>
        @view?.setJournalMessage('touch')

      # All these links are present on the journal
      @view.delegate 'click', '#equipe-btn', =>
        @view.toggleJournal()
      @view.delegate 'click', '#invite-btn', @onClickFacebook
      @view.delegate 'click', '#hall-of-fame', =>
        @view.dim => @redirectTo 'hall-of-fame'
    , =>
      # Error callback, if facebook fail. Nothing to display. Retry ?
      @view?.setJournalMessage('error')


  onClickFacebook: =>
    FacebookHelper.getOtherFriends (friends) =>
      # Check if everyone is invited
      if _.difference(_.pluck(friends, 'id'), Parse.User.current().get('fb_invited')).length < 1 and FacebookHelper.isLinked()
         popUp.initialize {message: i18n.t('controller.home.app_request.error'), title: 'Action impossible', key: 'appRequest-error'}
      else
        FacebookHelper.friendRequest i18n.t('controller.home.facebook_invite_message'), =>
          popUp.initialize {message: i18n.t('controller.home.app_request.success'), title: 'Invitations envoyées', key: 'appRequest-success'}
        , =>
          popUp.initialize {message: i18n.t('controller.home.app_request.error'), title: 'Action impossible', key: 'appRequest-error'}


  getJournalView: (friends, callback) ->
    switch friends.length
      when 0 then @getSmallLeaderboard @getNoFriendsJournalView, callback
      when 1 then @getFriendsScore friends, @getOneFriendJournalView, callback
      when 2 then @getFriendsScore friends, @getTwoFriendsJournalView, callback
      else        @getFriendsScore friends, @getTwoplusFriendsJournalView, callback

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
    return new NoFriendsJournalView options


  getFriendsScore: (friends, journalView, callback) ->
    friendsId = _.pluck(friends, 'id')
    Parse.Cloud.run 'getFriendsScore', { friendsId: friendsId },
      success: (players) =>
        players.push Parse.User.current().attributes
        players = players.sort (f1, f2) ->
          f2.score - f1.score
        callback()
        @view.addJournalView journalView(players)
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

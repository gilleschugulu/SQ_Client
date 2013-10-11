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
    user = Parse.User.current()
    @loadView 'home'
    , =>
      new HomePageView {hearts: user.get('health'), credits: user.get('credits')}
    , (view) =>
      if mediator.justLaunched and ChartBoost? and no
        setTimeout =>
          # Track event
          AnalyticsHelper.trackEvent 'Splash', "ChartBoost Splash"
          @checkReloadPlayer(user)
          ChartBoost.showInterstitial (response) =>
            @viewLoaded view
        , 1000
      else
        @viewLoaded view
    , {viewTransition: yes}

  viewLoaded: (view) =>
    navigator.splashscreen.hide() if navigator?.splashscreen?.hide?
    @view?.setJournalMessage('loading')

    @view.delegate 'click', '#game-link', =>
      AnalyticsHelper.trackEvent 'Home', 'Click', 'Jouer'
      user = Parse.User.current()
      if user.get('health') > 0
        @view.dim => @redirectTo 'game'
      else
        AnalyticsHelper.trackEvent 'Home', 'Jouer', 'Pas assez de Jetons'
        popUp.initialize {template: 'no-more-coins'}

    FacebookHelper.getFriends (friends) =>
      @getJournalView friends, =>
        @view?.setJournalMessage('touch', yes)

      # All these links are present on the journal
      @view.delegate 'click', '#equipe-btn', =>
        AnalyticsHelper.trackEvent 'Home', 'Click', 'Journal'
        @view.toggleJournal()
      @view.delegate 'click', 'a', @onClickALink
      @view.delegate 'click', '#invite-btn', @onClickFacebook
      @view.delegate 'click', '#ranking', =>
        AnalyticsHelper.trackEvent 'Home', 'Click', 'Classement'
        @view.dim => @redirectTo 'hall-of-fame/home'
    , =>
      # Error callback, if facebook fail. Nothing to display. Retry ?
      @view?.setJournalMessage('error')

  onClickFacebook: =>
    AnalyticsHelper.trackEvent 'Home', 'Click', 'Inviter amis'
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
      when 0
        @getSmallLeaderboard @getNoFriendsJournalView, callback
        AnalyticsHelper.trackEvent 'Home', 'Journal', 'Pas d\'amis' if mediator.justLaunched
      when 1
        @getFriendsScore friends, @getOneFriendJournalView, callback
        AnalyticsHelper.trackEvent 'Home', 'Journal', '1 ami' if mediator.justLaunched
      when 2
        @getFriendsScore friends, @getTwoFriendsJournalView, callback
        AnalyticsHelper.trackEvent 'Home', 'Journal', '2 amis' if mediator.justLaunched
      else
        @getFriendsScore friends, @getTwoplusFriendsJournalView, callback
        AnalyticsHelper.trackEvent 'Home', 'Journal', 'Plus de 2 amis' if mediator.justLaunched
    mediator.setJustLaunched no

  getNoFriendsJournalView: (people) ->
    targetDate = new Date()
    targetDate.setHours(0)
    targetDate.setMinutes(0)
    targetDate.setSeconds(0)
    targetDate.setDate(targetDate.getDate() - targetDate.getDay() + 7)

    pip.fb_id = Math.round(Math.random()*1000000) for pip in people when not pip.fb_id

    options =
      targetDate  : targetDate
      username    : Parse.User.current().get('username')
      fb_id       : Parse.User.current().get('fb_id')
      participants: people
    return new NoFriendsJournalView options


  getFriendsScore: (friends, journalView, callback) ->
    friendsId = _.pluck(friends, 'id')
    Parse.Cloud.run 'getFriendsScore', { friendsId: friendsId, userId: Parse.User.current().id },
      success: (players) =>
        players = players.sort (f1, f2) ->
          f2.score - f1.score
        callback()
        @view?.addJournalView journalView(players)
      error: (error) ->
        console.log 'ERROR : ', error

  getSmallLeaderboard: (journalView, callback) ->
    Parse.Cloud.run 'smallLeaderboard', {size : 3},
      success: (players) =>
        players = players.sort (f1, f2) ->
          f2.score - f1.score
        @view?.addJournalView journalView(players)
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
    userId = Parse.User.current().id
    rank = _.find(players, (player) ->
      player.object_id == userId
    ).position

    name = Parse.User.current().get('username')
    if rank < 4
      title = i18n.t "controller.home.journal.twoplus.rank_#{rank}", name
    else
      title = i18n.t "controller.home.journal.twoplus.rank_n", name, rank, null
    options =
      title       : title
      participants: players

    new TwoplusFriendsJournalView options

  checkReloadPlayer: (user) ->
    # Rank can changed at the end of "contest". Contest is updated every week.
    # Refetch user if week change
    if mediator.isStillSameWeek() is false
      Parse.User.current().fetch
        success: ->
          console.log 'Player reloaded'

  onClickALink: (e) =>
    links =
      '#hall-of-fame/home' : 'Classemenet'
      '#options'           : 'Options'
      '#profile'           : 'Profil'
      '#shop'              : 'Boutique'
    super e, 'Home', links
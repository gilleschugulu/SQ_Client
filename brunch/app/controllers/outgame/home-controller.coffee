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

    FacebookHelper.getFriends (friends) =>
      @getJournalView(friends)

      # All these links are present on the journal
      @view.delegate 'click', '#equipe-btn', =>
        @view.toggleJournal()
      @view.delegate 'click', '#invite-btn', @onClickFacebook
      @view.delegate 'click', '#hall-of-fame', =>
        @view.dim => @redirectTo 'hall-of-fame'

      @view.delegate 'click', '#game-link', =>
        @view.dim => @redirectTo 'game'

  onClickFacebook: =>
    FacebookHelper.friendRequest i18n.t('controller.home.facebook_invite_message')

  getJournalView: (friends) ->
    switch friends.length
      when 0 then @view.addJournalView @getNoFriendsJournalView()
      when 1 then @getFriendsScore friends, @getOneFriendJournalView
      when 2 then @getFriendsScore friends, @getTwoFriendsJournalView
      else @getFriendsScore friends, @getTwoplusFriendsJournalView

  getNoFriendsJournalView: ->
    targetDate = new Date()
    targetDate.setHours(0)
    targetDate.setMinutes(0)
    targetDate.setSeconds(0)
    targetDate.setDate(targetDate.getDate() - targetDate.getDay() + 7)

    options =
      targetDate : targetDate
      name : 'forever a.'
      picture : 'http://media.comicvine.com/uploads/7/77914/2109064-4char_forever_alone_guy_high_resolution_icon.png'
      p1 :
        name : 'Toto T.'
        picture : 'https://graph.facebook.com/pierre.chugulu/picture'
        score : '22 999'
        rank : 1
      p2 :
        name : 'Tata T.'
        picture : 'https://graph.facebook.com/francois.chugulu/picture'
        score : '2 999'
        rank : 100
      p3 :
        name : 'Tutu T.'
        picture : 'https://graph.facebook.com/vincent.chugulu/picture'
        score : '999'
        rank : 1000
    return new NoFriendsJournalView options


  getFriendsScore: (friends, callback) ->
    friendsId = _.pluck(friends, 'id')

    Parse.Cloud.run 'getFriendsScore', { friendsId: friendsId },
      success: (players) =>
        players.push Parse.User.current().attributes
        players = players.sort (f1, f2) ->
          f2.score - f1.score
        @view.addJournalView callback(players)
        # callback(friends)
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
    options = 
      name: Parse.User.current().get('username')
      rank: _.indexOf(players, Parse.User.current().attributes) + 1
      participants: players

    new TwoplusFriendsJournalView options

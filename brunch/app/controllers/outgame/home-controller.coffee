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

    FacebookHelper.getFriends (friends) => view.addJournalView @getJournalView(friends)

    @view.delegate 'click', '#game-link', =>
      @view.dim => @redirectTo 'game'

    @view.delegate 'click', '#equipe-btn', =>
      @view.toggleJournal()

    @view.delegate 'click', '#hall-of-fame', =>
      @view.dim => @redirectTo 'hall-of-fame'

    @view.delegate 'click', '#invite-btn', @onClickFacebook

  onClickFacebook: =>
    FacebookHelper.friendRequest i18n.t('controller.home.facebook_invite_message')

  getJournalView: (friends) ->
    console.log 'getJournalView', friends, friends.length
    switch friends.length
      when 0 then @getNoFriendsJournalView()
      when 1 then @getOneFriendJournalView()
      when 2 then @getTwoFriendsJournalView()
      else @getTwoplusFriendsJournalView()

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

  getOneFriendJournalView: (friends) ->
    options =
      winner : 'jide'
      loser : 'gilles b.'
      participants : [
          name : 'Jide'
          picture : 'https://graph.facebook.com/pierre.chugulu/picture'
          score : '22 999'
        ,
          name : 'Gilles B.'
          picture : 'https://graph.facebook.com/francois.chugulu/picture'
          score : '2 999'
      ]

    new OneFriendJournalView options

  getTwoFriendsJournalView: (friends) ->
    options =
      master : 'gilles b.'
      participants : [
          name : 'Gilles B.'
          picture : 'https://graph.facebook.com/pierre.chugulu/picture'
          score : '22 999'
        ,
          name : 'Jide'
          picture : 'https://graph.facebook.com/francois.chugulu/picture'
          score : '2 999'
        ,
          name : 'Vincent'
          picture : 'https://graph.facebook.com/vincent.chugulu/picture'
          score : '999'
      ]

    return new TwoFriendsJournalView options

  getTwoplusFriendsJournalView: (friends) ->
    options =
      name : 'Gilles B.'
      rank : 4
      participants : [
          rank : 1
          picture : 'https://graph.facebook.com/francois.chugulu/picture'
          name : 'Ferdi'
          score : '43 456'
        ,
          rank : 2
          picture : 'https://graph.facebook.com/francois.chugulu/picture'
          name : 'Jide'
          score : '33 456'
        ,
          rank : 3
          picture : 'https://graph.facebook.com/francois.chugulu/picture'
          name : 'Eunk.Y'
          score : '23 456'
        ,
          rank : 4
          picture : 'https://graph.facebook.com/francois.chugulu/picture'
          name : 'Gilles B.'
          score : '13 456'
        ,
          rank : 5
          picture : 'https://graph.facebook.com/francois.chugulu/picture'
          name : 'Matteo B.'
          score : '3 456'
        ,
          rank : 6
          picture : 'https://graph.facebook.com/francois.chugulu/picture'
          name : 'Toto U.'
          score : '1 456'
        ,
          rank : 7
          picture : 'https://graph.facebook.com/francois.chugulu/picture'
          name : 'Jean D.'
          score : '456'
      ]
    new TwoplusFriendsJournalView options

Controller      = require 'controllers/base/controller'
HomePageView    = require 'views/outgame/home-page-view'
mediator        = require 'mediator'
FacebookHelper  = require 'helpers/facebook-helper'
AnalyticsHelper = require 'helpers/analytics-helper'

module.exports = class HomeController extends Controller
  historyURL: 'home'
  title: 'Home'

  index: ->
    PushNotifications?.unblock() # display any queued notifications
    @loadView 'home'
    , =>
      date = new Date()
      d = if date.getDate() < 10 then '0' + date.getDate() else date.getDate()
      d += '/'
      d += if date.getMonth() < 9 then '0' + (date.getMonth() + 1) else (date.getMonth() + 1)
      d += '/' + (date.getYear() % 100)
      new HomePageView {hearts:42, credits: 1337, date: d}
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
    setInterval =>
      @view.updateCountDown parseInt(Math.random() * 100), parseInt(Math.random() * 24), parseInt(Math.random() * 60)
    , 1000
    @view.delegate 'click', '#game-link', =>
      @view.dim => @redirectTo 'game'

    @view.delegate 'click', '#equipe-btn', =>
      @view.toggleJournal()

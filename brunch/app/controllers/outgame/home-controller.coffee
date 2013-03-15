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
      new HomePageView()
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

    @view.delegate 'click', '#game-link', =>
      @view.dim => @redirectTo 'game'

Controller      = require 'controllers/base/controller'
AnalyticsHelper = require 'helpers/analytics-helper'
ProfileView     = require 'views/outgame/profile-view'
mediator        = require 'mediator'
FacebookHelper  = require 'helpers/facebook-helper'
ConfigHelper    = require 'helpers/config-helper'
ApiCallHelper   = require 'helpers/api-call-helper'

module.exports = class ProfilesController extends Controller
  title     : 'Profile'
  historyURL: 'profile'
  stats : null

  index: =>
    @loadStats()
    @loadView 'profile'
      , =>
        new ProfileView()
      , (view) =>
        view.delegate 'click', '#link-fb', @linkFacebook
        view.delegate 'click', '.rankings', @onClickGameCenter
        view.updateStats @stats if @stats
      , {viewTransition: yes, music: 'outgame'}

  linkFacebook: ->
    # Track Event
    AnalyticsHelper.trackEvent 'Profil', 'Liaison facebook'

    # Call Facebook for linking
    FacebookHelper.getLoginStatus(false, true)

  onClickGameCenter: =>
    # Track Event
    AnalyticsHelper.trackEvent 'Profil', 'Affichage de Game Center'

    console.log "GC"
    lb = ConfigHelper.config.gamecenter.leaderboard
    if lb
      GameCenter?.showLeaderboard lb
    else
      alert('pas de leaderboard')

  loadStats: =>
    ApiCallHelper.fetch.playerStats mediator.user.get('uuid'), (stats) =>
      @stats = stats.player
      @view?.updateStats @stats

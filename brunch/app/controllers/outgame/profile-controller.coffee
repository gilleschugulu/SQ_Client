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
    @user = Parse.User.current()
    @user.set('score', 234234).save()
    console.log @user
    @loadView 'profile'
      , =>
        new ProfileView({user : @user.attributes})
      , (view) =>
        view.delegate 'click', '.facebook-link', @linkFacebook
        view.delegate 'click', '.game-center', @onClickGameCenter
      , {viewTransition: yes, music: 'outgame'}

  linkFacebook: ->
    # Track Event
    AnalyticsHelper.trackEvent 'Profil', 'Liaison facebook'

    # Call Facebook for linking
    FacebookHelper.getLoginStatus(false, true)

  onClickGameCenter: =>
    # Track Event
    AnalyticsHelper.trackEvent 'Profil', 'Affichage de Game Center'

    lb = ConfigHelper.config.gamecenter.leaderboard
    if lb
      GameCenter?.showLeaderboard lb
    else
      alert('pas de leaderboard')


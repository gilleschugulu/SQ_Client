Controller      = require 'controllers/base/controller'
AnalyticsHelper = require 'helpers/analytics-helper'
ProfileView     = require 'views/outgame/profile-view'
mediator        = require 'mediator'
FacebookHelper  = require 'helpers/facebook-helper'
ConfigHelper    = require 'helpers/config-helper'
GameStatHelper  = require 'helpers/game-stat-helper'
I18n            = require 'lib/i18n'

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
        stats = GameStatHelper.getProfileStat()
        stats_stats = _.map _.omit(stats, 'all_sports'), (val, key) ->
          name: key
          number: val
          text: I18n.t('controller.profile.stats.' + key)
        stats_sports = _.map stats.all_sports, (val, key) ->
          number: val.percent
          text: val.name
          name: key

        new ProfileView({ user : @user.attributes, stats: stats_stats, sports: stats_sports })

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


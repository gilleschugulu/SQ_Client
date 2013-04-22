Controller      = require 'controllers/base/controller'
AnalyticsHelper = require 'helpers/analytics-helper'
ProfileView     = require 'views/outgame/profile-view'
mediator        = require 'mediator'
FacebookHelper  = require 'helpers/facebook-helper'
ConfigHelper    = require 'helpers/config-helper'
GameStatHelper  = require 'helpers/game-stat-helper'
I18n            = require 'lib/i18n'
User            = require 'models/outgame/user-model'

module.exports = class ProfilesController extends Controller
  title     : 'Profile'
  historyURL: 'profile'
  stats : null

  index: =>

    @user = new User(Parse.User.current().attributes)
    if fb_id = @user.get('fb_id')
      # TODO : Size must be dynamic
      avatar = 'https://graph.facebook.com/' + fb_id + '/picture?width=150&height=170'
    else
      avatar = 'images/common/facebook-default.jpg'
    
    @loadView 'profile'
      , =>
        stats = GameStatHelper.getProfileStat()
        stats_stats = _.map stats.stats, (val, key) ->
          name: key
          number: val
          text: I18n.t('controller.profile.stats.' + key)
        stats_stats.game_week_score = stats.score
        stats_sports = _.map stats.sports, (val, key) ->
          number: val.percent
          text: val.name
          name: key

        new ProfileView({ user : @user.attributes, stats: stats_stats, sports: stats_sports, bonus: @user.getBonuses(), avatar, is_linked: Parse.FacebookUtils.isLinked(Parse.User.current()) })

      , (view) =>
        view.delegate 'click', '.facebook-link', @linkFacebook
        view.delegate 'click', '.game-center', @onClickGameCenter
        view.autoSizeText()
      , {viewTransition: yes, music: 'outgame'}

  linkFacebook: ->
    return if Parse.FacebookUtils.isLinked(Parse.User.current())
    # Track Event
    AnalyticsHelper.trackEvent 'Profil', 'Liaison facebook'

    # Call Facebook for linking
    FacebookHelper.getLoginStatus(false, true)
    @view.activateFbButton()

  onClickGameCenter: =>
    # Track Event
    AnalyticsHelper.trackEvent 'Profil', 'Affichage de Game Center'

    lb = ConfigHelper.config.gamecenter.leaderboard
    if lb
      GameCenter?.showLeaderboard lb
    else
      alert('Pas de leaderboard')
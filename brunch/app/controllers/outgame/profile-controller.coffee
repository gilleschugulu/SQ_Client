Controller      = require 'controllers/base/controller'
AnalyticsHelper = require 'helpers/analytics-helper'
ProfileView     = require 'views/outgame/profile-view'
mediator        = require 'mediator'
FacebookHelper  = require 'helpers/facebook-helper'
ConfigHelper    = require 'helpers/config-helper'
PopUpHelper     = require 'helpers/pop-up-helper'
GameStatHelper  = require 'helpers/game-stat-helper'
I18n            = require 'lib/i18n'
User            = require 'models/outgame/user-model'

module.exports = class ProfilesController extends Controller
  title     : 'Profile'
  historyURL: 'profile'
  stats : null

  index: =>

    @user = new User(Parse.User.current().attributes)

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
          text: val.name.substring(0, 12)
          name: key

        new ProfileView({ user : @user.attributes, stats: stats_stats, sports: stats_sports, bonus: @user.getBonuses(), fb_id : @user.get('fb_id'), is_linked: FacebookHelper.isLinked(), gamecenter: GameCenter? })

      , (view) =>
        view.delegate 'click', '.picture', @linkFacebook
        view.delegate 'click', '.game-center', @onClickGameCenter
        view.autoSizeText()
      , {viewTransition: yes}

  linkFacebook: =>
    return if FacebookHelper.isLinked()
    # Track Event
    AnalyticsHelper.trackEvent 'Profil', 'Click', 'Liaison facebook'

    @view.facebookLink()
    # Call Facebook for linking
    FacebookHelper.linkPlayer (user) =>
      @view.displayFbAvatar user.get('fb_id')
      # FacebookHelper.unlinkPlayer()
    , (user, error) =>
      @view.facebookLink yes
      console.log "link FB shitted"
      console.log error
      if error and error.code is Parse.Error.ACCOUNT_ALREADY_LINKED
        PopUpHelper.initialize {message: 'Ce compte Facebook est déjà lié à un autre compte du jeu', title: 'Erreur', key: 'api-error'}
      else
        PopUpHelper.initialize {message: 'Erreur avec Facebook', title: 'Erreur', key: 'api-error'}

  onClickGameCenter: =>
    # Track Event
    AnalyticsHelper.trackEvent 'Profil', 'Click', 'Affichage de Game Center'

    lb = ConfigHelper.config.gamecenter.leaderboard
    console.log GameCenter?.showLeaderboard
    if lb
      GameCenter?.showLeaderboard lb
    else
      alert('Pas de leaderboard')


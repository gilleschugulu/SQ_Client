Controller         = require 'controllers/base/controller'
OptionsView        = require 'views/outgame/options-view'
LocalStorageHelper = require 'helpers/local-storage-helper'
ApiCallHelper      = require 'helpers/api-call-helper'
SoundHelper        = require 'helpers/sound-helper'
AnalyticsHelper    = require 'helpers/analytics-helper'
mediator           = require 'mediator'
DeviceHelper       = require 'helpers/device-helper'

module.exports = class OptionsController extends Controller
  historyURL: 'options'
  title: 'Options'

  index: =>
    @setLocalOption 'option-info-notif',    mediator.user.get('notifications').info
    @setLocalOption 'option-ranking-notif', mediator.user.get('notifications').ranking
    @setLocalOption 'option-level-notif',   mediator.user.get('notifications').decrease_rank

    @loadView null
    , =>
      # initialize buttons with the correct state
      templateData =
        music        : if SoundHelper.musicMuted then 'off' else '' # sounds helper : music on/off
        fx           : if SoundHelper.sfxMuted then 'off' else '' # sounds helper : fx on/off
        info_notif   : if @getLocalOption('option-info-notif', 'true') is 'false' then 'off' else ''
        level_notif  : if @getLocalOption('option-level-notif', 'true') is 'false' then 'off' else ''
        ranking_notif: if @getLocalOption('option-ranking-notif', 'true') is 'false' then 'off' else ''
        facebook     : 'off' # facebook helper: connected to fb

      new OptionsView({templateData})
    , (view) =>
      # bind actions
      view.delegate 'click', '#option-music',            @onClickToggleMusic
      view.delegate 'click', '#option-fx',               @onClickToggleFX
      view.delegate 'click', '#option-info-notif',       @onClickToggleInfoNotif
      view.delegate 'click', '#option-level-notif',      @onClickToggleLevelNotif
      view.delegate 'click', '#option-ranking-notif',    @onClickToggleRankingNotif
      view.delegate 'click', '#option-help',             @onClickHelp
      view.delegate 'click', '#option-facebook-connect', @onClickFacebookConnect
    , {viewTransition: yes, music: 'outgame'}


  # Option management
  getLocalOption: (key, defaultValue) =>
    LocalStorageHelper.get(key) || defaultValue

  setLocalOption: (key, value) =>
    LocalStorageHelper.set key, value

  toggleRemoteOption: (key, remoteKey) =>
    filters = {}
    newValue = if @getLocalOption(key, 'true') is 'true' then 'false' else 'true'
    filters[remoteKey] = newValue
    ApiCallHelper.send.notificationFilters mediator.user.get('uuid'), filters, (response) =>
      # Track Event
      AnalyticsHelper.trackEvent 'Options', "#{key} = #{newValue}"

      @setLocalOption key, newValue
      @view.toggleButton key
    # on error
      # display message

  # Actions
  # -------
  # uservoice

  onClickHelp: =>
    # Track Event
    AnalyticsHelper.trackEvent 'Options', "Demander de l'aide"

    uvData = mediator.user.get('uuid') || "Joueur-non-connecté"
    uvData += ' / ' + DeviceHelper.device()
    uvData += ' / ' + BuildVersion.toString() if BuildVersion
    UserVoice.setCustomFields {UUID_Version : uvData}
    UserVoice.showPopupWidget()


  # link account
  onClickFacebookConnect: =>
    # Track Event
    AnalyticsHelper.trackEvent 'Options', "Liaison facebook"

  onClickToggleFX: =>
    @view.toggleButton 'option-fx'
    SoundHelper.toggleSFX()

  onClickToggleMusic: =>
    @view.toggleButton 'option-music'
    SoundHelper.toggleMusic()

  onClickToggleRankingNotif: =>
    @toggleRemoteOption 'option-ranking-notif', 'ranking'

  onClickToggleLevelNotif: =>
    @toggleRemoteOption 'option-level-notif', 'decrease_rank'

  onClickToggleInfoNotif: =>
    @toggleRemoteOption 'option-info-notif', 'info'

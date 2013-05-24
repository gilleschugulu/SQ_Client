Controller         = require 'controllers/base/controller'
OptionsView        = require 'views/outgame/options-view'
LocalStorageHelper = require 'helpers/local-storage-helper'
SoundHelper        = require 'helpers/sound-helper'
AnalyticsHelper    = require 'helpers/analytics-helper'
mediator           = require 'mediator'
DeviceHelper       = require 'helpers/device-helper'
SpinnerHelper      = require 'helpers/spinner-helper'
FacebookHelper     = require 'helpers/facebook-helper'

module.exports = class OptionsController extends Controller
  historyURL: 'options'
  title: 'Options'

  index: =>
    @setLocalOption 'option-info-notif', Parse.User.current().get('notifications')

    @loadView null
    , =>
      # initialize buttons with the correct state
      templateData =
        music        : if SoundHelper.musicMuted then 'off' else '' # sounds helper : music on/off
        fx           : if SoundHelper.sfxMuted then 'off' else '' # sounds helper : fx on/off
        info_notif   : if @getLocalOption('option-info-notif', 'true') is 'false' then 'off' else ''
        facebook     : if FacebookHelper.isLinked() then 'off' else '' # facebook helper: connected to fb

      new OptionsView({templateData})
    , (view) =>
      # bind actions
      view.delegate 'click', '#option-sound',            @onClickToggleSound
      view.delegate 'click', '#option-info-notif',       @onClickToggleInfoNotif
      view.delegate 'click', '#option-help',             @onClickHelp
      view.delegate 'click', '#option-facebook-connect', @onClickFacebookConnect
    , {viewTransition: yes}


  # Option management
  getLocalOption: (key, defaultValue) =>
    LocalStorageHelper.get(key) || defaultValue

  setLocalOption: (key, value) =>
    LocalStorageHelper.set key, value

  # Actions
  # -------
  # uservoice

  onClickHelp: =>
    # Track Event
    AnalyticsHelper.trackEvent 'Options', "Demander de l'aide"
    rawurlencode: (str) ->
      str = (str + '').toString();
      encodeURIComponent(str).replace(/!/g, '%21').replace(/'/g, '%27').replace(/\(/g, '%28').replace(/\)/g, '%29').replace(/\*/g, '%2A')
    uvData = Parse.User.current().id || "Joueur-non-connecté"
    uvData += ' / ' + DeviceHelper.device()
    uvData += ' / ' + BuildVersion.toString() if BuildVersion
    uvData = "Votre message ici\n\n\ninformations pour les développeurs. Veuillez ne pas y toucher\n" + uvData
    if Message?
      mail =
        to  : ["lequipe@chugulu.com"]
        body: uvData
        html: no
      Message.composeMail mail
    else
      window.open("mailto:lequipe@chugulu.com?body=" + rawurlencode(uvData), 'width=700,height=500') if window


  # link account
  onClickFacebookConnect: =>
    # Track Event
    AnalyticsHelper.trackEvent 'Options', "Liaison facebook"
    FacebookHelper.linkPlayer() unless FacebookHelper.isLinked()

  onClickToggleSound: =>
    @view.toggleButton 'option-sound'
    SoundHelper.toggleSound()

  onClickToggleInfoNotif: =>
    user = Parse.User.current()
    newVal = !user.get('notifications')
    user.set 'notifications', newVal
    SpinnerHelper.start()
    user.save null,
      success : =>
        SpinnerHelper.stop()
        @setLocalOption 'option-info-notif', newVal
        @view.toggleButton 'option-info-notif'
      error : =>
        SpinnerHelper.stop()

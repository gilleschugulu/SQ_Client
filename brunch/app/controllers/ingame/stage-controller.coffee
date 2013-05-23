Controller  = require 'controllers/base/controller'
PopUpHelper = require 'helpers/pop-up-helper'
SoundHelper = require 'helpers/sound-helper'

module.exports = class StageController extends Controller
  model   : null # stage model
  assetKey: null # asset preloading
  name    : null # stage name
  type    : null # stage type
  i18n_key: null # stage i18n_key

  # pause related
  paused  : no   # pause status
  onResume: null # callback on resume

  initialize: (stage) ->
    @assetKey = stage.name
    @name     = stage.name
    @type     = stage.type
    @i18n_key = stage.i18n_key
    document.addEventListener 'pause', @onResignActive, false
    # document.addEventListener 'resume', @onBecomeActive, false
    super

  finishStage: =>
    @publishEvent 'game:finish'

  setStageModel: (@model) ->
    @

  start: ->
    @view?.delegate 'click', '.btn-menu', @pause
    SoundHelper.play @name

  pause: =>
    return if @paused
    @paused = yes
    console.log "paused"
    @subscribeEvent 'popup:pause:ok', @resume
    templateData =
      key: 'pause'
      template: 'pause'
      sound: if SoundHelper.soundMuted then 'off' else '' # sounds helper : music on/off
    PopUpHelper.initialize templateData

  resume: =>
    return unless @paused
    @paused = no
    console.log "resumed"
    @onResume?()
    @onResume = null

  # iOS interruptions
  # -----------------
  onResignActive: (e) =>
    @pause()

  # / iOS interruptions

  dispose: ->
    @timer?.destroy()
    document.removeEventListener 'pause', @onResignActive, false
    # document.removeEventListener 'resume', @onBecomeActive, false
    super
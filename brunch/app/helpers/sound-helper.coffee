LocalStorageHelper = require 'helpers/local-storage-helper'
AnalyticsHelper    = require 'helpers/analytics-helper'

module.exports = class SoundHelper
  @sounds           = {}
  @musicMuted       = no
  @sfxMuted         = no
  @currentMusicKey  = null

  @initialize: ->
    @musicMuted = LocalStorageHelper.get('musicMuted') is 'true'
    @sfxMuted   = LocalStorageHelper.get('sfxMuted') is 'true'
    SoundConfig = require 'config/sound-config'
    for s in SoundConfig.sounds
      @sounds[s.key] =
        type : s.type
        sound: new buzz.sound(SoundConfig.assetPath + '/' + s.type + '/' + s.file, s.opts)

  @play = (key, initializeIfNeeded = true) ->
    return unless (sound = @sounds[key])
    return if @sfxMuted and sound.type is 'sfx'
    @currentMusicKey = key if sound.type is 'music'
    return if @musicMuted and (sound.type is 'music' or sound.type is 'jingle')
    @sounds[key].sound.stop()
    @sounds[key].sound.play()

  @resumeMusic = ->
    return unless @currentMusicKey or @musicMuted
    @play @currentMusicKey

  @pause = (key = @currentMusicKey) ->
    @sounds[key].sound.pause()

  @stop = (key = @currentMusicKey) ->
    @sounds[key].sound.stop()

  @togglePlay : (key) ->
    @sounds[key].sound.togglePlay()

  @stopAll = ->
    buzz.all().stop()

  @getDuration = (key, fallbackDuration = 1000) ->
    duration = @sounds[key].sound.getDuration() * 1000
    if isNaN duration then duration = fallbackDuration
    duration

  @fadeOut: (key, duration, callback) ->
    @sounds[key].sound.fadeOut duration, callback

  @fadeIn: (key, duration, callback) ->
    @sounds[key].sound.fadeIn duration, callback

  @fadeWith: (firstKey, secondKey, duration) ->
    @sounds[firstKey].sound.fadeWith secondKey, duration

  @areSoundsMuted: ->
    @musicMuted and @sfxMuted

  # Toggle ALL sounds : music, jingle and sfx
  @toggleSound = ->
    @toggleMusic()
    @toggleSFX()

  @toggleMusic = ->
    @musicMuted = !@musicMuted

    LocalStorageHelper.set('musicMuted', @musicMuted) # @musicMuted is a boolean, but will be stocked as string : 'true' or 'false'
    for key, sound of @sounds when sound.type is 'music' or sound.type is 'jingle'
      @stop(key) if @musicMuted
    @play(@currentMusicKey) if @currentMusicKey and not @musicMuted

  @toggleSFX = ->
    @sfxMuted = !@sfxMuted

    LocalStorageHelper.set('sfxMuted', @sfxMuted) # @sfxMuted is a boolean, but will be stocked as string : 'true' or 'false'
    for key, sound of @sounds when sound.type is 'sfx'
      @stop(key) if @sfxMuted

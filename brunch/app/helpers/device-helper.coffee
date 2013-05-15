module.exports = class DeviceHelper

  @tag              = "DeviceHelper"
  @_userAgent       = null
  @_windowSize      = null
  @_isMobile        = null
  @_isAndroid       = null
  @_isIOS           = null
  @_isIPad          = null
  @_isIPhone        = null
  @_isIPod          = null
  @_isRetina        = null
  @_resolution      = null
  @_localization    = null
  @_animationGrade  = null

  @getWindowSize = ->
    @_windowSize ?= {width : $(window).width(), height: $(window).height()}

  @getAppSize = ->
    {width : $('#global-container').width(), height: $('#global-container').height()}  #Don't want to cache, to handle resize of window

  @getAppSizeCategory = ->
    width = @getAppSize().width
    if width > 1023
      'ipad'
    else if width < 959
      'iPhone'
    else
      'web'

  @device = ->
    if @isMobile() then 'mobile' else 'web'

  @isMobile = ->
    @_isMobile ?= @isAndroid() or @isIOS()

  @isAndroid = ->
    @_isAndroid ?= @userAgentMatch "android"

  @isIOS = ->
    @_isIOS ?= @isIPad() or @isIPhone() or @isIPod()

  @isIPad = ->
    @_isIPad ?= @userAgentMatch "ipad"

  @isIPhone = ->
    @_isIPhone ?= @userAgentMatch "iphone"

  @isIPod = ->
    @_isIPod ?= @userAgentMatch "ipod"

  @isIOS = ->
    @_isIOS ?= @isIPad() or @isIPhone() or @isIPod()

  @isRetina = ->
    @_isRetina ?= @getResolution() == 2

  @getResolution = ->
    @_resolution ?= window.devicePixelRatio or 1

  @getLocalization = ->
    if navigator.language?
      @_localization ?= navigator.language.substr(0, 2)
    else if navigator.browserLanguage?
      @_localization ?= navigator.browserLanguage.substr(0, 2)
    @_localization

  @userAgentMatch = (string) ->
    @getUserAgent().indexOf(string) > -1

  @getUserAgent = ->
    @_userAgent ?= navigator.userAgent.toLowerCase()

  @getAnimationGrade = (callback) ->
    if not @_animationGrade?
      # check local storage
      _restoreGrade = localStorage.getItem('device_animation_grade')
      if not _restoreGrade?
        return BenchmarkHelper.test (grade) =>
          @_animationGrade = grade
          localStorage.setItem('device_animation_grade', grade)
          callback(@_animationGrade) if typeof callback isnt "undefined"
      else
        @_animationGrade = parseInt(_restoreGrade)

    callback(@_animationGrade) if typeof callback isnt "undefined"
    @_animationGrade

  @canPerformAnimation = ->
    @_animationGrade < 2

  @isIPhone5 = ->
    if screen.availWidth is 320 and screen.availHeight is 568
      @_isIPhone5 = true
      return true
    else
      return false

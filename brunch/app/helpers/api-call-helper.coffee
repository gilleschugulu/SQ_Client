PopUpHelper  = require 'helpers/pop-up-helper'
ConfigHelper = require 'helpers/config-helper'
config       = require 'config/environment-config'
mediator     = require 'mediator'
spinner      = require 'helpers/spinner-helper'
i18n         = require 'lib/i18n'

module.exports = class ApiCallHelper
  @requests = {}
  @abortAll : ->
    console.group "ABORTING REQUEST(S)"
    for url,xhr of @requests
      delete @requests[url]
      console.log url
      xhr.abort()
    console.log "ABORTION DONE"
    console.groupEnd()

  # Fetch Data Helper
  # -----------------
  @fetch:
    # Fetch Player
    # ------------
    player: (uuid, callback, errorCallback) =>
      url = ConfigHelper.getAPIURLFor 'getPlayer', {uuid}
      @request url, null, callback, errorCallback

    # Fetch Player with provider
    # --------------------------
    playerWithProvider: (params, callback, errorCallback) =>
      url = ConfigHelper.getAPIURLFor('getPlayerWithProvider', params.to_change) + $.param(params.url)
      @request url, null, callback, errorCallback

    # Fetch Player With Email and Code
    # --------------------------------
    playerWithCode: (params, callback, errorCallback) =>
      url = ConfigHelper.getAPIURLFor('getPlayerWithCode') + $.param(params)
      @request url, null, callback, errorCallback

    playerStats: (uuid, callback, errorCallback) =>
      url = ConfigHelper.getAPIURLFor('getPlayerStats', {uuid})
      @request url, null, callback, errorCallback

    # Fetch Game
    # ----------
    game: (uuid, callback, errorCallback) =>
      url = ConfigHelper.getAPIURLFor 'gameStart'
      @request url, {uuid}, callback, errorCallback, {httpMethod : 'POST'}

    getCreditPacks: (callback) =>
      url = ConfigHelper.getAPIURLFor 'getCreditPacks'
      @request url, null, callback

    getLeaderboards: (params, callback) =>
      url = ConfigHelper.getAPIURLFor('getLeaderboards') + $.param(params)
      @request url, null, callback

    moreGames: (callback, errorCallback) =>
      url = ConfigHelper.config.urls.more_games
      @request url, null, callback, errorCallback, {dataType : 'html'}

  # Send Data Helper
  # ----------------
  @send:
    # Create Player
    # -------------
    createPlayer: (params, callback, errorCallback) =>
      url = ConfigHelper.getAPIURLFor 'createPlayer'
      @request url, params, callback, errorCallback, {httpMethod : 'POST'}

    # Create Player with provider
    # ---------------------------
    createPlayerWithProvider: (params, callback, errorCallback) =>
      url = ConfigHelper.getAPIURLFor 'createPlayerWithProvider', params.to_change
      @request url, params.url, callback, errorCallback, {httpMethod : 'POST'}

    # Link Player to priver
    # ---------------------
    linkPlayerWithProvider: (params, callback, errorCallback) =>
      url = ConfigHelper.getAPIURLFor 'linkProvider', params.to_change
      @request url, params.url, callback, errorCallback, {httpMethod : 'POST'}

    # Update Player
    # -------------
    updatePlayer: (params, callback, errorCallback) =>
      url = ConfigHelper.getAPIURLFor 'updatePlayer', params.to_change
      @request url, params.url, callback, errorCallback, {httpMethod : 'PUT'}

    # Send notifications preferences of the user
    # ------------------------------------------
    notificationFilters: (uuid, filters, success) =>
      url = ConfigHelper.getAPIURLFor 'notificationFilters', {uuid : uuid}
      @request url, {player: {filters: filters}}, success, null, {httpMethod : 'PUT'}

    gameFinish: (data, success, error) =>
      url = ConfigHelper.getAPIURLFor 'gameFinish'
      @request url, data, success, error, {httpMethod : 'POST'}

    registerPushToken: (data, success, error) =>
      url = ConfigHelper.getAPIURLFor 'registerPushToken'
      @request url, data, success, error, {spinner : no, abortable : no, httpMethod : 'POST'}

    friendDefeated: (uuid) =>
      url = ConfigHelper.getAPIURLFor 'friendDefeated', {uuid: uuid}
      @request url, null, null, null, {spinner: no, abortable: no, httpMethod: 'GET'}


  # Ajax Call
  # ---------
  @defaultOptions =
    dataType  : 'json'
    httpMethod: 'GET'
    abortable : yes
    apiVersion: 1
    spinner   : yes
  @request: (url, params, callback, errorCallback, options = {}) =>
    options[k] = v for k,v of @defaultOptions when not options[k]? # merge with defaults

    # no internet connection, tell user, do nothing
    if navigator.connection? and Connection? and (navigator.connection.type is Connection.NONE or navigator.connection.type is Connection.UNKNOWN)
      PopUpHelper.initialize
        title  : i18n.t('helper.apiCall.error.title')
        message: i18n.t('helper.apiCall.error.connection')
        key    : 'network-error'
      return

    error = (rawResponse) =>
      apiResponse = {}
      if rawResponse.status? and rawResponse.status isnt 0 and rawResponse.status isnt 503 # when server unavailable / 503
        try
          apiResponse = JSON.parse(rawResponse.responseText)
        catch e

      if errorCallback? # let the calleR method handle the error response
        errorCallback(apiResponse, rawResponse)

      else if apiResponse.error?.messages? # server responded with parsable JSON (API error)var lol
        # Initiliaze popup with the error messages
        PopUpHelper.initialize
          title  : i18n.t('helper.apiCall.error.title')
          message: apiResponse.error.messages
          key    : 'api-error'

      else # server responded with txt, html, etc (server error)
        PopUpHelper.initialize
          title  : i18n.t('helper.apiCall.error.title')
          message: i18n.t('helper.apiCall.error.server')
          key    : 'server-error'

    xhr = $.ajax
      type      : options.httpMethod
      url       : url
      data      : params
      dataType  : options.dataType
      headers   : ConfigHelper.getAPIHeaders options.apiVersion, i18n.getLocale()
      success   : callback
      error     : (xhr, errorType, err) =>
        if @requests[url]? or not options.abortable # if the request wasn't canceled
          error(xhr, errorType, err)
      beforeSend: -> spinner.startPartial() if options.spinner
      complete  : =>
        delete @requests[url] if @requests[url]? # remove from the queue on complete (if not canceled)
        spinner.stopPartial() if options.spinner

    @requests[url] = xhr if options.abortable
    xhr

console.log "SUBSCRIBE MEDIATOR"
mediator.subscribe 'apicalls:abort', => ApiCallHelper.abortAll()

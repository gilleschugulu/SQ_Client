Application = require 'application'

waitForDeviceReadyEvent = (callback) ->
  # device ready already fired
  if Cordova?.onDeviceReady?.fired or navigator.userAgent.match(/iP((a|o)d|hone)/i) is null
    console.log "device ready already fired"
    callback()
  else
    console.log "waiting for device response"
    document.addEventListener "deviceready", callback, no

# Initialize the application on DOM ready event.
$ ->
  app = new Application()
  waitForDeviceReadyEvent ->
    app.initialize()

  # Initiliaze FastClick, no more 300ms delay for clicks.
  new FastClick(document.body)
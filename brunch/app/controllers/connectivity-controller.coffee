DeviceHelper  = require 'helpers/device-helper'
Controller    = require 'controllers/base/controller'

module.exports = class ConnectivityController extends Controller
  getConnectionInterval: null
  displayed: no

  initialize: ->
    super
    console.log 'initialize'
    @checkConnection()
    @getConnectionInterval = setInterval(@checkConnection, 30000)

  checkConnection: =>
    if DeviceHelper.isConnected()
      @displayAlert no if @displayed
    else
      @displayAlert yes

  displayAlert: (lostConnection) ->
    el = $('.alert-connection', '#global-container')
    if lostConnection
      @displayed = yes
      el.addClass('active')
    else
      @displayed = no
      el.removeClass('active')

  dispose: ->
    clearInterval @getConnectionInterval
    delete @getConnectionInterval
    super

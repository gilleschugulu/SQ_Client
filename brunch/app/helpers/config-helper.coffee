# do not put configuration values directly here, use (local|preprod|prod)-config.coffee
# use this to simplify access to config values

# see environment-config.coffee

config = require 'config/environment-config'
utils  = require 'lib/utils'

module.exports = class ConfigHelper
  @config = config

  # returns full url for a given route name
  @getAPIURLFor : (routeName, params) ->
    @getAPIURLWithPath @config.api.routes[routeName], params

  # returns full url with a given path
  @getAPIURLWithPath : (path, params) ->
    if params?
      path = utils.addParams path, params
    @config.urls.base + path

  @getAPIHeaders : (apiVersion, locale) ->
    headers = {}
    headers[@config.api.headers.version] = apiVersion
    headers[@config.api.headers.locale]  = locale
    headers

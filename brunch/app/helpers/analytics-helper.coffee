config = require 'config/environment-config'

module.exports = class AnalyticsHelper

  @init: ->
    return unless config.analytics.enabled
    if config.analytics.google? and config.analytics.google instanceof Array
      GoogleAnalytics?.startTrackerWithAccountIDs config.analytics.google

  @trackPageView: (page) ->
    return unless config.analytics.enabled
    GoogleAnalytics?.trackPageview page

  @trackEvent: (category, action, label = '', value = 0) ->
    return unless config.analytics.enabled
    GoogleAnalytics?.trackEvent category, action, label, value

  # Type is Allopass, iOS or Chugulu (or Tapjoy?)
  # Price is the full price (send by server)
  @trackTransaction: (transactionHash) ->
    return unless config.analytics.enabled
    GoogleAnalytics?.trackTransaction transactionHash
    # AnalyticsHelper.trackTransaction AnalyticsHelper.getTransactionHash([pack], ConnectionHelper.getUUID())
    # XitiHelper.transaction XitiHelper.getTransactionHash([pack], ConnectionHelper.getUUID())
    # XitiHelper.page(['Boutique', 'Jeton', 'Pack_achete'], {f1: 'Itunes.' + pack.value} )

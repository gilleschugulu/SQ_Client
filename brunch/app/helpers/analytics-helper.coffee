config = require 'config/environment-config'
DeviceHelper = require 'helpers/device-helper'

module.exports = class AnalyticsHelper

  @init: ->
    return unless config.analytics.enabled
    if config.analytics.google? and config.analytics.google[DeviceHelper.device()] instanceof Array
      if GoogleAnalytics?
        GoogleAnalytics.startTrackerWithAccountIDs config.analytics.google[DeviceHelper.device()]
      else
        for id in config.analytics.google[DeviceHelper.device()]
          ga 'create', id, {'cookieDomain': 'none'}
          console.log id
        ga 'send', 'pageview'
        ga 'require', 'ecommerce', 'ecommerce.js'

  @trackPageView: (page) ->
    return unless config.analytics.enabled
    if GoogleAnalytics?
      GoogleAnalytics.trackPageview page
    else
      ga 'send', 'pageview', {title:page}

  @trackEvent: (category, action, label = '', value = 0) ->
    return unless config.analytics.enabled
    if GoogleAnalytics?
      GoogleAnalytics.trackEvent category, action, label, value
    else
      ga 'send', 'event', category, action, label, value

  # Type is Allopass, iOS or Chugulu (or Tapjoy?)
  # Price is the full price (send by server)
  @trackTransaction: (transactionHash) ->
    # return unless ENV.prod
    console.log "TRANSACTION HASH"
    console.log transactionHash
    if GoogleAnalytics?
      GoogleAnalytics.trackTransaction transactionHash
    else
      ga 'ecommerce:addTransaction', transactionHash.transaction
      ga 'ecommerce:addItem', item for item in transactionHash.items
      ga 'ecommerce:send'

  @getTransactionHash: (packs, uuid) ->
    transaction =
      id      : uuid + '_' + (new Date()).getTime()
      revenue : 0
      currency: 'EUR'
    items = []
    for product in packs
      if product.net_price
        price = product.net_price
      else
        storeTax = 1 - (product.storeTax || 0)
        VAT      = 1 + (product.vat || 0)
        price    = product.price Math.round(product.price / VAT * storeTax * 100) / 100
      item =
        id      : transaction.id
        name    : product.name
        sku     : product.product_id
        category: product.category
        price   : price
        quantity: 1
      transaction.revenue += price
      items.push item
    hash = {transaction, items}

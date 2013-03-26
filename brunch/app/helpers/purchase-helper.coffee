mediator        = require 'mediator'
ConfigHelper    = require 'helpers/config-helper'
SpinnerHelper   = require 'helpers/spinner-helper'
PopUpHelper     = require 'helpers/pop-up-helper'
FacebookHelper  = require 'helpers/facebook-helper'
i18n            = require 'lib/i18n'
AnalyticsHelper = require 'helpers/analytics-helper'

module.exports = class PurchaseHelper
  @tapPoints : 0

  @purchaseAppstoreRating: (pack, successCallback) ->
    user = Parse.User.current()

    AppStoreRating?.openRatingsPage (appVersion) ->
      user.increment('credits', pack.value).save()
      successCallback?(user.get('credits'))

  @purchaseTwitter: (pack, twitterConfig, successCallback) ->
    window.open('http://twitter.com', '_blank')
    successCallback?(Parse.User.current().get('credits'))


  @purchaseFacebookLike: (pack, successCallback) ->
    window.open('http://facebook.com', '_blank')
    user = Parse.User.current()
    user.increment('credits', pack.value).save()
    successCallback?(user.get('credits'))


  @purchaseFacebookInvitation: (pack, successCallback) ->
    user = Parse.User.current()

    FacebookHelper.friendRequest i18n.t('helper.purchase.facebook.invitation_text'), (response) =>
      # We don't need this shhh*t
      delete response.request


      # Filter friends already invited : local ? Parse ? Both ?

      # # Pushing id of friends invited into the array before sending
      friends_invited = []
      for to, id of response
        friends_invited.push id

      user.increment('credits', pack.value * friends_invited.length).save()
      successCallback?(user.get('credits'))

      PopUpHelper.initialize
        title  : 'info'
        message: response.info.messages
        key    : 'fb-reward'

  @purchaseTapjoy: (pack, currency, successCallback) ->
    user = Parse.User.current()

    if TapjoyConnect?
      TapjoyConnect.setUserID Parse.User.current().id
      TapjoyConnect.showOffersWithCurrencyID currency, no, =>
        TapjoyConnect.getTapPoints (points) =>
          console.log "TAPJOY POINTS"
          console.log @tapPoints
          console.log points
          console.log points - @tapPoints
          user.increment('credits', points - @tapPoints).save()
          @tapPoints = points
          successCallback?(user.get('credits'))

  @initTapPoints: ->
    TapjoyConnect.setUserID Parse.User.current().id
    TapjoyConnect?.getTapPoints (@tapPoints) =>

  @purchaseAdcolony: (pack, zone, successCallback) ->
    user = Parse.User.current()

    if AdColony?
      options =
        zone     : zone
        custom   : Parse.User.current().id
        # prepopup : yes
        # postpopup: yes
      AdColony.playVideo options, (amount) =>
        console.log "AD COLO : I gots some reward"
        console.log amount
        console.log Parse.User.current().get('credits')
        console.log Parse.User.current().get('credits') + amount
        # AnalyticsHelper.item('Pack de crédits AdColony', 'Visionné', pack.name, 0)
        # Parse.User.current().set('credits', amount + Parse.User.current().get('credits'))
        # successCallback?(Parse.User.current().get('credits'))

        # TODO : Pack doesn't have a constant value
        user.increment('credits', amount).save()
        successCallback?(user.get('credits'))

      , (error) =>
        console.log "AD COLO : fail"
        console.log error
        if error.code is AdColonyError.REWARD_UNAVAILABLE # no more rewards for today
          popupStuff =
            title  : i18n.t 'helper.purchase.adcolony.quota_exceeded.title'
            message: i18n.t 'helper.purchase.adcolony.quota_exceeded.message'
            key    : 'adcolony-fail'
        else
          popupStuff =
            title  : i18n.t 'helper.purchase.adcolony.error.title'
            message: i18n.t 'helper.purchase.adcolony.error.message'
            key    : 'adcolony-fail'
        PopUpHelper.initialize popupStuff

  @purchaseLife: (pack, successCallback) ->
    user = Parse.User.current()

    user.increment('health', pack.value).increment('credits', -pack.price).save()
    successCallback?(user.get('credits'), user.get('health'))

  @purchaseBonus: (pack, successCallback) ->
    user = Parse.User.current()
    bonus_added = pack.value
    bonuses = {}

    for name, value of user.get('bonus')
      bonuses[name] = value + bonus_added

    user.set('bonus', bonuses).increment('credits', -pack.price).save()

    successCallback?(user.get('credits'))

  @purchaseApple: (pack, successCallback) ->
    if pack.product_id and MKStore? and MKStore.gotProducts
      # AnalyticsHelper.item('Pack de crédits In App', 'click', pack.name, pack.price)
      SpinnerHelper.start()
      console.log pack.product_id
      # alert 'wait for it...'
      MKStore.buyFeature pack.product_id, (response) =>
        # Used by Google to track pack bought
        # AnalyticsHelper.trackTransaction AnalyticsHelper.getTransactionHash([pack], ConnectionHelper.getUUID())
        Parse.User.current().set 'credits', response.credits
        successCallback?(Parse.User.current().get('credits'))
        SpinnerHelper.stop()
      , (error) =>
        # Track event
        AnalyticsHelper.trackEvent 'Boutique', "Achat du pack #{pack.name} sucess", '', pack.price

        PopUpHelper.initialize
          title  : i18n.t 'helper.purchase.apple.error.title'
          message: i18n.t 'helper.purchase.apple.error.message'
          key    : 'purchase-fail'
        console.log "fail"
        console.log error.code # MKStoreError
        console.log error
        SpinnerHelper.stop()
      , =>
        # Track event
        AnalyticsHelper.trackEvent 'Boutique', "Achat du pack #{pack.name} error", '', pack.price

        PopUpHelper.initialize
          title  : i18n.t 'helper.purchase.apple.cancel.title'
          message: i18n.t 'helper.purchase.apple.cancel.message'
          key    : 'purchase-fail'
        console.log "canceled"
        SpinnerHelper.stop()
      , null
    else
      console.error "Trying to by pack without product_id OR did not getProducts()"

  @fetchAppleProducts: (packs, callback) ->
    return callback?({}) unless MKStore?
    SpinnerHelper.start()

    products =
      consumables   : {}
      nonConsumables: {}
      subscriptions : {}

    products.consumables[pack.product_id] = pack for pack in packs when pack.product_id

    MKStore.getProducts products, (availableProducts) =>
      SpinnerHelper.stop()
      callback?(availableProducts)
    , =>
      SpinnerHelper.stop()
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
      user.increment('credits', pack.value).save null,
        success: (user) -> successCallback?(user.get('credits'))
        error: (user, error) ->
          PopUpHelper.initialize
            title  : i18n.t 'helper.purchase.unknown_error.title'
            message: i18n.t 'helper.purchase.unknown_error.message'
            key    : 'rating-pack-ko'

  @purchaseTwitter: (pack, twitterConfig, successCallback) ->
    # TODO implement properly when needed (user.save etc)
    # window.open('http://twitter.com', '_blank')
    # successCallback?(Parse.User.current().get('credits'))


  @purchaseFacebookLike: (pack, successCallback) ->
    window.open('http://facebook.com', '_blank')
    Parse.User.current().increment('credits', pack.value).save null,
      success: (user) -> successCallback?(user.get('credits'))
      error: (user, error) ->
        PopUpHelper.initialize
          title  : i18n.t 'helper.purchase.unknown_error.title'
          message: i18n.t 'helper.purchase.unknown_error.message'
          key    : 'fblike-pack-ko'


  @purchaseFacebookInvitation: (pack, successCallback) ->
    # TODO implement properly when needed (user.save etc)
    return
    user = Parse.User.current()

    FacebookHelper.friendRequest i18n.t('helper.purchase.facebook.invitation.text'), (response) =>
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
        message: i18n.t('helper.purchase.facebook.invitation.reward')
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
    TapjoyConnect?.setUserID Parse.User.current().id
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
    Parse.User.current().increment('health', pack.value).increment('credits', -pack.price).save null,
      success: (user) -> # success
        AnalyticsHelper.trackEvent 'Boutique', "Pack de vie #{pack.value}", 'Achat confirmé', pack.price
        successCallback?(user.get('credits'), user.get('health'))
        PopUpHelper.initialize
          title  : i18n.t 'helper.purchase.pack_bought.title'
          message: i18n.t 'helper.purchase.pack_bought.message'
          key    : 'life-pack-ok'
      error: (user, error) ->
        AnalyticsHelper.trackEvent 'Boutique', "Pack de vie #{pack.value}", 'Error parse', pack.price
        PopUpHelper.initialize
          title  : i18n.t 'helper.purchase.unknown_error.title'
          message: i18n.t 'helper.purchase.unknown_error.message'
          key    : 'life-pack-ko'

  @purchaseBonus: (pack, successCallback) ->
    user = Parse.User.current()
    bonus_added = pack.value
    bonuses = {}

    for name, value of user.get('bonus')
      bonuses[name] = value + bonus_added

    user.set('bonus', bonuses).increment('credits', -pack.price).save null,
      success: (user) -> # success
        AnalyticsHelper.trackEvent 'Boutique', "Pack de bonus #{pack.value}", 'Achat confirmé', pack.price
        successCallback?(user.get('credits'))
        PopUpHelper.initialize
          title  : i18n.t 'helper.purchase.pack_bought.title'
          message: i18n.t 'helper.purchase.pack_bought.message'
          key    : 'bonus-pack-ok'
      error: (user, error) ->
        AnalyticsHelper.trackEvent 'Boutique', "Pack de bonus #{pack.value}", 'Error parse', pack.price
        PopUpHelper.initialize
          title  : i18n.t 'helper.purchase.unknown_error.title'
          message: i18n.t 'helper.purchase.unknown_error.message'
          key    : 'bonus-pack-ko'

  @purchaseApple: (pack, successCallback) ->
    if pack.product_id and MKStore? and MKStore.gotProducts
      SpinnerHelper.start()
      # alert 'wait for it...'
      MKStore.buyFeature pack.product_id, (response) =>
        Parse.User.current().increment('credits', pack.value).save null,
          success: (user) ->
            # Used by Google to track pack bought
            AnalyticsHelper.trackTransaction AnalyticsHelper.getTransactionHash([pack], user.id)
            successCallback?(user.get('credits'))
            AnalyticsHelper.trackEvent 'Boutique', "Pack payant #{pack.name}", 'Achat confirmé', pack.price
            SpinnerHelper.stop()
            PopUpHelper.initialize
              title  : i18n.t 'helper.purchase.pack_bought.title'
              message: i18n.t 'helper.purchase.pack_bought.message'
              key    : 'apple-pack-ok'
          error: (user, error) ->
            SpinnerHelper.stop()
            AnalyticsHelper.trackEvent 'Boutique', "Pack payant #{pack.name}", 'Error Parse', pack.price
            PopUpHelper.initialize
              title  : i18n.t 'helper.purchase.apple.error.title'
              message: i18n.t 'helper.purchase.apple.error.message'
              key    : 'purchase-fail'    
      , (error) =>
        # Track event
        AnalyticsHelper.trackEvent 'Boutique', "Pack payant #{pack.name}", 'Error ' + MKStore.getErrorName(error.code), pack.price
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
        AnalyticsHelper.trackEvent 'Boutique', "Pack payant #{pack.name}", 'Achat annulé', pack.price

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
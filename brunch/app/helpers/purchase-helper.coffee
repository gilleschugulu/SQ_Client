mediator        = require 'mediator'
ConfigHelper    = require 'helpers/config-helper'
SpinnerHelper   = require 'helpers/spinner-helper'
ApiCallHelper   = require 'helpers/api-call-helper'
PopUpHelper     = require 'helpers/pop-up-helper'
FacebookHelper  = require 'helpers/facebook-helper'
i18n            = require 'lib/i18n'
AnalyticsHelper = require 'helpers/analytics-helper'

module.exports = class PurchaseHelper
  @purchaseAppstoreRating: (successCallback) ->
    AppStoreRating?.openRatingsPage (appVersion) ->
      console.log appVersion
      # Formating params before calling API for reward
      params_reward =
        url:
          app_version : appVersion
        to_change:
          action: 'app_store_rating'
          uuid  : mediator.user.get('uuid')

      # Call the server API
      ApiCallHelper.send.updatePlayer params_reward
        , (response) -> # Success Callback
          console.log response
          mediator.user.set 'credits', response.player.credits
          successCallback?(mediator.user.get('credits'))


  @purchaseFacebookLike: (successCallback) ->
    # Formating params before calling API for reward
    params_reward =
      to_change:
        action: 'facebook_like'
        uuid  : mediator.user.get('uuid')

    ApiCallHelper.send.updatePlayer params_reward
      , (response) -> # Success Callback
        console.log 'Server give credits', response
        mediator.user.set 'credits', response.player.credits

        PopUpHelper.initialize
          title  : i18n.t 'helper.purchase.apple.error.title'
          message: i18n.t 'helper.purchase.apple.error.message'
          key    : 'purchase-fail'

        successCallback?(mediator.user.get('credits'))

  @purchaseFacebookInvitation: (successCallback) ->
    FacebookHelper.friendRequest i18n.t('helper.purchase.facebook.invitation_text'), (response) =>
      # We don't need this shhh*t
      delete response.request

      # Formating params before calling API for reward
      params_reward =
        url:
          friends      : response.to
          provider_name: 'facebook'
        to_change:
          action: 'invite_friends'
          uuid  : mediator.user.get('uuid')

      console.log 'Friends count : ', params_reward.url.friends

      # # Pushing id of friends invited into the array before sending
      # for to, id of response
      #   params_reward.url.friends.push id

      # Call the server API
      ApiCallHelper.send.updatePlayer params_reward
        , (response) -> # Success Callback
          console.log response
          mediator.user.set 'credits', response.info.data.player.credits
          successCallback?(mediator.user.get('credits'))
          PopUpHelper.initialize
            title  : 'info'
            message: response.info.messages
            key    : 'fb-reward'
        # , (response) -> # Error Callback
        #   console.log response

  @purchaseTapjoy: (currency, successCallback) ->
    if TapjoyConnect?
      TapjoyConnect.setUserID mediator.user.get 'uuid'
      TapjoyConnect.showOffersWithCurrencyID currency, no, =>
        # AnalyticsHelper.item('Pack de crédits Tapjoy', 'Visionné', pack.name, 0)
        currentBalance = mediator.user.get 'credits'
        ApiCallHelper.fetch.player mediator.user.get('uuid'), (response) =>
          console.log "fetch player after tapjoy"
          console.log response
          if currentBalance isnt response.credits
            # AnalyticsHelper.trackTransaction AnalyticsHelper.getTransactionHash([pack], ConnectionHelper.getUUID())
            mediator.user.set 'credits', response.player.credits
            successCallback?(mediator.user.get('credits'))

  @purchaseAdcolony: (zone, successCallback) ->
    if AdColony?
      options =
        zone     : zone
        custom   : mediator.user.get 'uuid'
        # prepopup : yes
        # postpopup: yes
      AdColony.playVideo options, (amount) =>
        console.log "AD COLO : I gots some reward"
        console.log amount
        console.log mediator.user.get('credits')
        console.log mediator.user.get('credits') + amount
        # AnalyticsHelper.item('Pack de crédits AdColony', 'Visionné', pack.name, 0)
        mediator.user.set('credits', amount + mediator.user.get('credits'))
        successCallback?(mediator.user.get('credits'))
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

  @purchaseApple: (pack, successCallback) ->
    if pack.product_id and MKStore? and MKStore.gotProducts
      # AnalyticsHelper.item('Pack de crédits In App', 'click', pack.name, pack.price)
      SpinnerHelper.start()

      # alert 'wait for it...'
      MKStore.buyFeature pack.product_id, (response) =>
        # Used by Google to track pack bought
        # AnalyticsHelper.trackTransaction AnalyticsHelper.getTransactionHash([pack], ConnectionHelper.getUUID())
        mediator.user.set 'credits', response.credits
        successCallback?(mediator.user.get('credits'))
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
      , {
          postData :
            uuid   : mediator.user.get 'uuid'
            sandbox: (if yes then 'true' else 'false')
          remoteProductServer : ConfigHelper.config.urls.base
      }
    else
      console.error "Trying to by pack without product_id OR did not getProducts()"

  @fecthAppleProducts: (packs, callback) ->
    return callback?({}) unless MKStore?
    SpinnerHelper.start()

    products =
      consumables   : {}
      nonConsumables: {}
      subscriptions : {}

    products.consumables[pack.product_id] = pack for pack in packs when pack.provider is 'apple' and pack.product_id

    MKStore.getProducts products, (availableProducts) =>
      SpinnerHelper.stop()
      callback?(availableProducts)
    , =>
      SpinnerHelper.stop()

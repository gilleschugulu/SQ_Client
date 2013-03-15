Controller         = require 'controllers/base/controller'
ShopView           = require 'views/outgame/shop-view'
ApiCallHelper      = require 'helpers/api-call-helper'
PurchaseHelper     = require 'helpers/purchase-helper'
ConfigHelper       = require 'helpers/config-helper'
mediator           = require 'mediator'
i18n               = require 'lib/i18n'
LocalStorageHelper = require 'helpers/local-storage-helper'
PopUpHelper        = require 'helpers/pop-up-helper'
AnalyticsHelper    = require 'helpers/analytics-helper'


module.exports = class ShopController extends Controller
  historyURL       : 'shop'
  title            : 'Shop'
  packs            : null
  availableProducts: {}

  index: =>
    # ApiCallHelper.fetch.getCreditPacks @onCreditPacksFetch
    response = {"count":4,"credit_packs":[{"id":3,"value":50,"name":"Mini Pack","product_id":"com.chugulu.cdm.minipack","position":0,"price":1.79,"created_at":"2013-02-05T15:07:37+01:00","updated_at":"2013-02-06T16:40:07+01:00","provider":"apple","image":"http://s3-eu-west-1.amazonaws.com/midi-dev/images/attachments/000/000/025/original/pack_minipack.png?2013"},{"id":5,"value":500,"name":"Plus populaire","product_id":"com.chugulu.cdm.poppack","position":2,"price":2.59,"created_at":"2013-02-05T15:52:45+01:00","updated_at":"2013-02-06T16:39:36+01:00","provider":"apple","image":"http://s3-eu-west-1.amazonaws.com/midi-dev/images/attachments/000/000/023/original/pack_lepluspopulaire.png?2013"},{"id":2,"value":50,"name":"Medium Pack","product_id":"com.chugulu.cdm.mediumpack","position":3,"price":9.99,"created_at":"2012-12-13T10:41:57+01:00","updated_at":"2013-02-06T16:31:45+01:00","provider":"apple","image":"http://s3-eu-west-1.amazonaws.com/midi-dev/images/attachments/000/000/021/original/pack_mediumpack.png?2013"},{"id":4,"value":5000,"name":"Meilleure offre","product_id":"com.chugulu.cdm.bestpack","position":4,"price":19.99,"created_at":"2013-02-05T15:50:52+01:00","updated_at":"2013-02-06T16:39:27+01:00","provider":"apple","image":"http://s3-eu-west-1.amazonaws.com/midi-dev/images/attachments/000/000/022/original/pack_lameilleureoffre.png?2013"}],"free_packs":{"adcolony":true,"tapjoy":true,"invite_friends":true,"facebook_like":true,"twitter":false,"app_store_rating":true}}
    @onCreditPacksFetch(response)

  onCreditPacksFetch: (response) =>
    @packs = response
    free = ['twitter', 'facebook_like', 'app_store_rating']
    for fp in free when @packs.free_packs[fp]
      @packs.free_packs[fp] = !LocalStorageHelper.exists "store_pack_#{fp}"

    @loadView 'shop'
    , =>
      console.log ConfigHelper.config.services.facebook
      new ShopView {@packs, credits:mediator.user.get('credits'), like_page_url: ConfigHelper.config.services.facebook.like_page_url}
    , (view) =>
      view.delegate 'click', '.paid-pack', @onClickApplePack
      view.delegate 'click', '.free-pack', @onClickFreePack
      PurchaseHelper.fecthAppleProducts @packs.credit_packs, (@availableProducts) =>
        view.disableUnavailablePacks (pack.id for pack in @packs.credit_packs when !@availableProducts[pack.product_id])
    , {viewTransition: yes, music: 'outgame'}

  onSuccessfulTransaction: (credits) =>
    @view.updateWallet credits

  onClickApplePack: (e) =>
    packId = parseInt @view.chooseApplePack(e.target)
    pack = (p for p in @packs.credit_packs when parseInt(p.id) is packId)?[0]
    if @availableProducts[pack.product_id]?
      PurchaseHelper.purchaseApple pack, @onSuccessfulTransaction
    else
      PopUpHelper.initialize
        title  : i18n.t 'controller.shop.unavailable_pack.title'
        message: i18n.t 'controller.shop.unavailable_pack.message'
        key    : 'pack-error'

  # Free packs
  # ----------
  onClickFreePack: (e) =>
    provider   = @view.chooseFreePack e.target
    methodName = $.zepto.camelize 'on-click-' + provider.replace(/_/g, '-')
    if @[methodName]
      @[methodName]()
    else
      console.error 'Unknown provider ' + provider + ' (' + methodName + ')'

  onClickAdcolony: =>
    # Track event
    AnalyticsHelper.trackEvent 'Boutique', 'Achat du pack AdColony'

    PurchaseHelper.purchaseAdcolony ConfigHelper.config.services.adcolony.zones.SHOP, @onSuccessfulTransaction

  onClickTapjoy: =>
    # Track event
    AnalyticsHelper.trackEvent 'Boutique', 'Achat du pack Tapjoy'

    PurchaseHelper.purchaseTapjoy ConfigHelper.config.services.tapjoy.currency, @onSuccessfulTransaction

  onClickFacebookInvitation: =>
    # Track event
    AnalyticsHelper.trackEvent 'Boutique', 'Achat du pack FaceBookInvitation'

    console.log "facebook invitation"
    PurchaseHelper.purchaseFacebookInvitation @onSuccessfulTransaction

  onClickAppStoreRating: =>
    # Track event
    AnalyticsHelper.trackEvent 'Boutique', 'Achat du pack AppStoreRating'

    PurchaseHelper.purchaseAppstoreRating (credits) =>
      @onSuccessfulTransaction credits
      @disableFreePack 'app_store_rating'

  onClickFacebookLike: =>
    # Track event
    AnalyticsHelper.trackEvent 'Boutique', 'Achat du pack FacebookLike'

    console.log "facebook like"
    PurchaseHelper.purchaseFacebookLike (credits) =>
      @onSuccessfulTransaction credits
      @disableFreePack 'facebook_like'

  disableFreePack: (type) ->
    @view.removeFreePack type
    LocalStorageHelper.set "store_pack_#{type}", 1
  # / Free packs

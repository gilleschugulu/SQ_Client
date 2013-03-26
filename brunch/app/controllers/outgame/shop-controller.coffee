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
PurchasePacks      = require 'config/purchase-config'
BonusPacks         = require 'config/bonus-config'

module.exports = class ShopController extends Controller
  historyURL       : 'shop'
  title            : 'Shop'
  packs            : null
  availableProducts: {}

  index: =>
    @packs = PurchasePacks
    @bonuses = BonusPacks
    user = Parse.User.current()


    @loadView 'shop'
    , =>
      console.log ConfigHelper.config.services.facebook
      new ShopView {@packs, @bonuses, health: user.get('health'), credits: user.get('credits'), like_page_url: ConfigHelper.config.services.facebook.like_page_url}
    , (view) =>
      view.delegate 'click', '#bonuses.inactive', @onToggleTab
      view.delegate 'click', '#credits.inactive', @onToggleTab

      view.delegate 'click', '.paid-pack', @onClickApplePack
      view.delegate 'click', '.free-pack', @onClickFreePack
      view.delegate 'click', '.life-pack', @onClickLifePack
      view.delegate 'click', '.bonus-pack', @onClickBonusPack
      PurchaseHelper.fetchAppleProducts @packs.credit_packs, (@availableProducts) =>
        view.disableUnavailablePacks (pack.id for pack in @packs.credit_packs when !@availableProducts[pack.product_id])

      # test faster, harder, stronger :D
      # @onToggleTab()

    , {viewTransition: yes, music: 'outgame'}

  onSuccessfulTransaction: (credits, life) =>
    @view.updateWallet credits, life

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
    methodName = $.camelCase 'on-click-' + provider.replace(/_/g, '-')
    if @[methodName]
      @[methodName]()
    else
      console.error 'Unknown provider ' + provider + ' (' + methodName + ')'

  onClickAdcolony: =>
    # Track event
    AnalyticsHelper.trackEvent 'Boutique', 'Achat du pack AdColony'

    PurchaseHelper.purchaseAdcolony ConfigHelper.config.services.adcolony.zones.SHOP, @onSuccessfulTransaction

  onClickTwitter: =>
    # Track event
    AnalyticsHelper.trackEvent 'Boutique', 'Suis Nous sur Twitter'

    PurchaseHelper.purchaseTwitter ConfigHelper.config.services.twitter, @onSuccessfulTransaction

  onClickTapjoy: =>
    # Track event
    AnalyticsHelper.trackEvent 'Boutique', 'Achat du pack Tapjoy'

    PurchaseHelper.purchaseTapjoy ConfigHelper.config.services.tapjoy.currency, @onSuccessfulTransaction

  onClickInviteFriends: =>
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


  onToggleTab: =>
    @view.toggleTabs()


  onClickLifePack: (e) =>
    pack = BonusPacks.life_packs[@view.chooseLifePackIndex e.target]
    return unless pack

    if Parse.User.current().get('credits') >= pack.price
      PurchaseHelper.purchaseLife pack, @onSuccessfulTransaction
    else
      PopUpHelper.initialize
        title  : i18n.t 'controller.shop.not_enough_credits.title'
        message: i18n.t 'controller.shop.not_enough_credits.message'
        key    : 'pack-error'

  onClickBonusPack: (e) =>
    pack = BonusPacks.bonus_packs[@view.chooseBonusPackIndex e.target]
    return unless pack

    if Parse.User.current().get('credits') >= pack.price
      PurchaseHelper.purchaseBonus pack, @onSuccessfulTransaction
    else
      PopUpHelper.initialize
        title  : i18n.t 'controller.shop.not_enough_credits.title'
        message: i18n.t 'controller.shop.not_enough_credits.message'
        key    : 'pack-error'
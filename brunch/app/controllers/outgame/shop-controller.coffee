Controller         = require 'controllers/base/controller'
ShopView           = require 'views/outgame/shop-view'
PurchaseHelper     = require 'helpers/purchase-helper'
DeviceHelper       = require 'helpers/device-helper'
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
    @packs.type = (if DeviceHelper.isIOS() then 'ios' else 'web')
    if fp = @packs.free_packs[@packs.type]
      @packs.free_packs = fp
      for p,index in @packs.free_packs
        @packs.free_packs[index].disabled = LocalStorageHelper.exists "store_pack_#{p.name}"
    @bonuses = BonusPacks
    user = Parse.User.current()
    PurchaseHelper.initTapPoints()

    @loadView 'shop'
    , =>
      new ShopView {@packs, @bonuses, health: user.get('health'), credits: user.get('credits'), like_page_url: ConfigHelper.config.services.facebook.like_page_url}
    , (view) =>
      view.delegate 'click', '#bonuses.inactive', =>
        @onToggleTab 'bonus'
      view.delegate 'click', '#credits.inactive', =>
        @onToggleTab 'credits'

      view.delegate 'click', '.paid-pack.ios', @onClickApplePack
      view.delegate 'click', '.paid-pack.web', @onClickAllopassPack
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
    packId = @view.chooseApplePack(e.currentTarget)
    pack = (p for p in @packs.credit_packs when p.product_id is packId)?[0]
    if @availableProducts[pack.product_id]?
      PurchaseHelper.purchaseApple pack, @onSuccessfulTransaction
    else
      PopUpHelper.initialize
        title  : i18n.t 'controller.shop.unavailable_pack.title'
        message: i18n.t 'controller.shop.unavailable_pack.message'
        key    : 'pack-error'

  onClickAllopassPack: (pack) ->
    return console.log('Yep, you clicked')
    # dataSend = AllopassHelper.generateData(pack.id, ConnectionHelper.getUUID(), pack.name, pack.price)
    # url = 'https://payment.allopass.com/buy/buy.apu?' + AllopassHelper.productUrl(pack.product_id) + '&data=' + dataSend
    # allopassChild = window.open(url, 'Sport Quiz 2 - Allopass', 'width=700,height=500,menubar=no') if window

    # inverval = setInterval =>
    #   console.log 'Window still here ? Sure ?'
    #   if allopassChild.closed
    #     current_credit = app.player_data.credit
    #     GameFetchHelper.fetchPlayer ConnectionHelper.getUUID(), (response) =>
    #       if current_credit == response.credits
    #         AnalyticsHelper.item('Pack de jetons Allopass', 'Annulation', pack.name, pack.price)
    #       else
    #         AnalyticsHelper.trackTransaction AnalyticsHelper.getTransactionHash([pack], ConnectionHelper.getUUID())
    #         XitiHelper.transaction XitiHelper.getTransactionHash([pack], ConnectionHelper.getUUID())
    #         XitiHelper.page(['Boutique', 'Jeton', 'Pack_achete'], {f1: 'Allopass.' + pack.value} )
    #         @updateWallet(response.credits)
    #     clearInterval(inverval)
    # , 500

  # Free packs
  # ----------
  onClickFreePack: (e) =>
    provider   = @view.chooseFreePack e.currentTarget
    methodName = $.camelCase 'on-click-' + provider.replace(/_/g, '-')
    pack = (pack for pack in @packs.free_packs when pack.name == provider)[0]

    if @[methodName]
      @[methodName](pack)
    else
      console.error 'Unknown provider ' + provider + ' (' + methodName + ')'

  onClickAdcolony: (pack) =>
    # Track event
    AnalyticsHelper.trackEvent 'Boutique', 'Achat du pack AdColony'

    PurchaseHelper.purchaseAdcolony pack, ConfigHelper.config.services.adcolony.zones.SHOP, @onSuccessfulTransaction

  onClickTwitter: (pack) =>
    # Track event
    AnalyticsHelper.trackEvent 'Boutique', 'Suis Nous sur Twitter'

    PurchaseHelper.purchaseTwitter pack, ConfigHelper.config.services.twitter, (credits) =>
      @onSuccessfulTransaction credits
      @disableFreePack 'twitter'

  onClickTapjoy: (pack) =>
    # Track event
    AnalyticsHelper.trackEvent 'Boutique', 'Achat du pack Tapjoy'

    PurchaseHelper.purchaseTapjoy pack, ConfigHelper.config.services.tapjoy.currency, @onSuccessfulTransaction

  onClickInviteFriends: (pack) =>
    # Track event
    AnalyticsHelper.trackEvent 'Boutique', 'Achat du pack FaceBookInvitation'

    console.log "facebook invitation"
    PurchaseHelper.purchaseFacebookInvitation pack, @onSuccessfulTransaction

  onClickAppStoreRating: (pack) =>
    # Track event
    AnalyticsHelper.trackEvent 'Boutique', 'Achat du pack AppStoreRating'

    PurchaseHelper.purchaseAppstoreRating pack, (credits) =>
      @onSuccessfulTransaction credits
      @disableFreePack 'app_store_rating'

  onClickFacebookLike: (pack) =>
    # Track event
    AnalyticsHelper.trackEvent 'Boutique', 'Achat du pack FacebookLike'

    console.log "facebook like"
    PurchaseHelper.purchaseFacebookLike pack, (credits) =>
      @onSuccessfulTransaction credits
      @disableFreePack 'facebook_like'

  disableFreePack: (type) ->
    @view.removeFreePack type
    LocalStorageHelper.set "store_pack_#{type}", 1
  # / Free packs


  onToggleTab: (tab) =>
    @view.toggleTabs(tab)


  onClickLifePack: (e) =>
    pack = BonusPacks.life_packs[@view.chooseLifePackIndex e.currentTarget]
    return unless pack

    if Parse.User.current().get('credits') >= pack.price
      PurchaseHelper.purchaseLife pack, @onSuccessfulTransaction
      PopUpHelper.initialize
        title: i18n.t 'controller.shop.life_pack_bought.title'
        message: i18n.t 'controller.shop.life_pack_bought.message'
        info: true
        confirmation: false
        key: 'life-pack-ok'
    else
      PopUpHelper.initialize
        title  : i18n.t 'controller.shop.not_enough_credits.title'
        message: i18n.t 'controller.shop.not_enough_credits.message'
        key    : 'pack-error'

  onClickBonusPack: (e) =>
    pack = BonusPacks.bonus_packs[@view.chooseBonusPackIndex e.currentTarget]
    return unless pack

    if Parse.User.current().get('credits') >= pack.price
      PurchaseHelper.purchaseBonus pack, @onSuccessfulTransaction
      PopUpHelper.initialize
        title: i18n.t 'controller.shop.bonus_pack_bought.title'
        message: i18n.t 'controller.shop.bonus_pack_bought.message'
        info: true
        confirmation: false
        key: 'bonus-pack-ok'
    else
      PopUpHelper.initialize
        title  : i18n.t 'controller.shop.not_enough_credits.title'
        message: i18n.t 'controller.shop.not_enough_credits.message'
        key    : 'pack-error'
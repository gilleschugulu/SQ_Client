Controller         = require 'controllers/base/controller'
ShopView           = require 'views/outgame/shop-view'
PurchaseHelper     = require 'helpers/purchase-helper'
DeviceHelper       = require 'helpers/device-helper'
ConfigHelper       = require 'helpers/config-helper'
mediator           = require 'mediator'
i18n               = require 'lib/i18n'
PopUpHelper        = require 'helpers/pop-up-helper'
AnalyticsHelper    = require 'helpers/analytics-helper'
SoundHelper        = require 'helpers/sound-helper'
SpinnerHelper      = require 'helpers/spinner-helper'

module.exports = class ShopController extends Controller
  historyURL       : 'shop'
  title            : 'Shop'
  packs            : null
  availableProducts: {}

  index: =>
    if mediator.packs?
      @displayPacks()
    else
      SpinnerHelper.start()
      Parse.Cloud.run 'shop_config', {},
        success: (packs) =>
          SpinnerHelper.stop()
          mediator.packs = packs
          @displayPacks()
        error: (error) =>
          SpinnerHelper.stop()
          console.log 'ERROR : ', error
          PopUpHelper.initialize
            title  : i18n.t 'controller.shop.fetch_packs_error.title'
            message: i18n.t 'controller.shop.fetch_packs_error.message'
            key    : 'fetch-packs-error'
            ok     : => @redirectTo 'home'


  displayPacks: =>
    user = Parse.User.current()
    @packs = mediator.packs
    @packs.type = (if DeviceHelper.isIOS() then 'ios' else 'web')
    if fp = (@packs.free_packs[@packs.type] ? @packs.free_packs)
      @packs.free_packs = fp
      for p,index in @packs.free_packs
        @packs.free_packs[index].disabled = user.get('free_packs') and !!user.get('free_packs')[p.name]

    @loadView 'shop'
    , =>
      new ShopView {@packs, health: user.get('health'), credits: user.get('credits'), like_page_url: ConfigHelper.config.services.facebook.like_page_url}
    , (view) =>
      view.delegate 'click', '#bonuses.inactive', =>
        AnalyticsHelper.trackEvent 'Boutique', 'Click', 'Bonus & vies'
        @onToggleTab 'bonus'
      view.delegate 'click', '#credits.inactive', =>
        AnalyticsHelper.trackEvent 'Boutique', 'Click', 'Jetons'
        @onToggleTab 'credits'

      view.delegate 'click', '.paid-pack.ios', @onClickApplePack
      view.delegate 'click', '.paid-pack.web', @onClickAllopassPack
      view.delegate 'click', '.free-pack', @onClickFreePack
      view.delegate 'click', '.life-pack', @onClickLifePack
      view.delegate 'click', '.bonus-pack', @onClickBonusPack
      PurchaseHelper.fetchAppleProducts @packs.credit_packs, (@availableProducts) =>
        view.disableUnavailablePacks (pack.id for pack in @packs.credit_packs when !@availableProducts[pack.product_id])

    , {viewTransition: yes}

  onSuccessfulTransaction: (credits, life) =>
    setTimeout =>
      @view.updateWallet credits, life
      SoundHelper.play('buy')
    , 0

  onClickApplePack: (e) =>
    packId = @view.chooseApplePack(e.currentTarget)
    pack = (p for p in @packs.credit_packs when p.product_id is packId)?[0]

    AnalyticsHelper.trackEvent 'Boutique', 'Click', 'Pack Jetons ' + pack.value, pack.net_price

    if @availableProducts[pack.product_id]?
      PurchaseHelper.purchaseApple pack, @onSuccessfulTransaction
    else
      AnalyticsHelper.trackEvent 'Boutique', 'Pack payant ' + packId, 'Pas disponnible'
      PopUpHelper.initialize
        title  : i18n.t 'controller.shop.unavailable_pack.title'
        message: i18n.t 'controller.shop.unavailable_pack.message'
        key    : 'pack-error'

  onClickAllopassPack: (e) =>
    packId = @view.chooseApplePack(e.currentTarget)
    pack = (p for p in @packs.credit_packs when p.product_id is packId)?[0]
    # AnalyticsHelper.trackTransaction AnalyticsHelper.getTransactionHash([pack], Parse.User.current().id)
    return console.log('Yep, you clicked', pack)
    # dataSend = AllopassHelper.generateData(pack.id, ConnectionHelper.getUUID(), pack.name, pack.net_price)
    # url = 'https://payment.allopass.com/buy/buy.apu?' + AllopassHelper.productUrl(pack.product_id) + '&data=' + dataSend
    # allopassChild = window.open(url, 'Sport Quiz 2 - Allopass', 'width=700,height=500,menubar=no') if window

    # inverval = setInterval =>
    #   console.log 'Window still here ? Sure ?'
    #   if allopassChild.closed
    #     current_credit = app.player_data.credit
    #     GameFetchHelper.fetchPlayer ConnectionHelper.getUUID(), (response) =>
    #       if current_credit == response.credits
    #         AnalyticsHelper.item('Pack de jetons Allopass', 'Annulation', pack.name, pack.net_price)
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
    AnalyticsHelper.trackEvent 'Boutique', 'Click', 'Achat du pack AdColony'

    PurchaseHelper.purchaseAdcolony pack, ConfigHelper.config.services.adcolony.zones.SHOP, @onSuccessfulTransaction

  onClickTwitter: (pack) =>
    # Track event
    AnalyticsHelper.trackEvent 'Boutique', 'Click', 'Suis Nous sur Twitter'

    PurchaseHelper.purchaseTwitter pack, ConfigHelper.config.services.twitter, (credits) =>
      @onSuccessfulTransaction credits
      @disableFreePack 'twitter'

  onClickTapjoy: (pack) =>
    # Track event
    AnalyticsHelper.trackEvent 'Boutique', 'Click', 'Achat du pack Tapjoy'

    PurchaseHelper.purchaseTapjoy pack, ConfigHelper.config.services.tapjoy.currency, @onSuccessfulTransaction

  onClickInviteFriends: (pack) =>
    # Track event
    AnalyticsHelper.trackEvent 'Boutique', 'Click', 'Achat du pack FaceBookInvitation'

    console.log "facebook invitation"
    PurchaseHelper.purchaseFacebookInvitation pack, @onSuccessfulTransaction

  onClickAppStoreRating: (pack) =>
    # Track event
    AnalyticsHelper.trackEvent 'Boutique', 'Click', 'Noter le jeu'

    PurchaseHelper.purchaseAppstoreRating pack, (credits) =>
      @onSuccessfulTransaction credits
      @disableFreePack 'app_store_rating'

  onClickFacebookLike: (pack) =>
    # Track event
    AnalyticsHelper.trackEvent 'Boutique', 'Click', 'Achat du pack FacebookLike'

    console.log "facebook like"
    PurchaseHelper.purchaseFacebookLike pack, (credits) =>
      @onSuccessfulTransaction credits
      @disableFreePack 'facebook_like'

  disableFreePack: (type) ->
    @view.removeFreePack type
    user = Parse.User.current()
    fp = user.get('free_packs') ? {}
    fp[type] = yes
    user.set('free_packs', fp).save()
  # / Free packs


  onToggleTab: (tab) =>
    @view.toggleTabs(tab)


  onClickLifePack: (e) =>
    pack = @packs.life_packs[@view.chooseLifePackIndex e.currentTarget]
    return unless pack
    AnalyticsHelper.trackEvent 'Boutique', 'Click', "Pack Vies #{pack.value}", pack.price

    if Parse.User.current().get('credits') >= pack.price
      PurchaseHelper.purchaseLife pack, @onSuccessfulTransaction
    else
      AnalyticsHelper.trackEvent 'Boutique', "Pack Vies #{pack.value}", 'Pas assez de jetons', pack.price
      PopUpHelper.initialize
        title  : i18n.t 'controller.shop.not_enough_credits.title'
        message: i18n.t 'controller.shop.not_enough_credits.message'
        key    : 'pack-error'

  onClickBonusPack: (e) =>
    pack = @packs.bonus_packs[@view.chooseBonusPackIndex e.currentTarget]
    return unless pack

    AnalyticsHelper.trackEvent 'Boutique', 'Click', "Pack Bonus #{pack.value}", pack.price

    if Parse.User.current().get('credits') >= pack.price
      PurchaseHelper.purchaseBonus pack, @onSuccessfulTransaction
    else
      AnalyticsHelper.trackEvent 'Boutique', "Pack Bonus #{pack.value}", 'Pas assez de jetons', pack.price
      PopUpHelper.initialize
        title  : i18n.t 'controller.shop.not_enough_credits.title'
        message: i18n.t 'controller.shop.not_enough_credits.message'
        key    : 'pack-error'

  onClickALink: (e) =>
    links =
      '#home' : 'Home'
    super e, 'Boutique', links
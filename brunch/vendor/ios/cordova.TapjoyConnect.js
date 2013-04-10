// Copyright (C) 2011-2012 by TapjoyConnect Inc.
//
// This file is part of the TapjoyConnect SDK.
//
// By using the TapjoyConnect SDK in your software, you agree to the terms of the TapjoyConnect SDK License Agreement.
//
// The TapjoyConnect SDK is bound by the TapjoyConnect SDK License Agreement and can be found here: https://www.tapjoy.com/sdk/license


var TapjoyConnect = {
  TJC_DISPLAY_AD_SIZE_320X50 : "320x50",
  TJC_DISPLAY_AD_SIZE_640X100 : "640x100",
  TJC_DISPLAY_AD_SIZE_768X90 : "768x90",
  serviceName : 'TapjoyConnect',
/**
 * Initialize TapjoyConnect Connect
 *
 * @param appID       The TapjoyConnect App ID.
 * @param secretKey     The TapjoyConnect Secret Key.
 * @param successCallback The success callback
 * @param failureCallback The error callback
 */
  requestTapjoyConnect : function(appID, secretKey, successCallback, failureCallback) {
  return cordova.exec(
                        successCallback,
                        failureCallback,
                        this.serviceName,
                        "requestTapjoyConnect",
                        [{appID:appID, secretKey:secretKey}]);
  },

/**
 * Initialize TapjoyConnect Connect with flags
 *
 * @param appID       The TapjoyConnect App ID.
 * @param secretKey     The TapjoyConnect Secret Key.
 * @param flags       TapjoyConnect Connect flags.
 * @param successCallback The success callback
 * @param failureCallback The error callback
 */
  requestTapjoyConnectWithFlags : function(appID, secretKey, flags, successCallback, failureCallback) {
  // Populate the hashtable.
  for (var name in flags) {
    cordova.exec(
                      successCallback,
                      failureCallback,
                      this.serviceName,
                      "setFlagKeyValue",
                     [{key:name, value:flags[name]}]);
  }

  return cordova.exec(
                         null,
                         null,
                         this.serviceName,
                         "requestTapjoyConnect",
                        [{appID:appID, secretKey:secretKey}]);
  },

/**
 * Sets a userID for this device/account.  This can only be used with non-managed currency and must be called before
 * showing the Marketplace, Display ads, Featured ad, etc.
 *
 * @param userID      The ID you wish to use for this user/account.
 * @param successCallback The success callback
 * @param failureCallback The error callback
 */
  setUserID : function(userID, successCallback, failureCallback) {
  return cordova.exec(
                        successCallback,
                        failureCallback,
                        this.serviceName,
                        "setUserID",
                        [{userID:userID}]);
  },


/**
 * Pay Per Action.
 *
 * @param actionID      PPA ID.
 * @param successCallback The success callback
 * @param failureCallback The error callback
 */
  actionComplete : function(actionID, successCallback, failureCallback) {
  return cordova.exec(
                        successCallback,
                        failureCallback,
                        this.serviceName,
                        "actionComplete",
                        [{actionID:actionID}]);
  },


/**
 * Show Marketplace
 *
 * @param successCallback The success callback
 * @param failureCallback The error callback
 */
  showOffers : function(successCallback, failureCallback) {
  return cordova.exec(
                        successCallback,
                        failureCallback,
                        this.serviceName,
                        "showOffers",
                        []);
  },


/**
 * Show Marketplace with a currency ID
 *
 * @param currencyID    The TapjoyConnect currency ID
 * @param selector      Whether to show the currency selector or not
 * @param successCallback The success callback
 * @param failureCallback The error callback
 */
  showOffersWithCurrencyID : function(currencyID, selector, successCallback, failureCallback) {
  return cordova.exec(
                        successCallback,
                        failureCallback,
                        this.serviceName,
                        "showOffersWithCurrencyID",
                        [{currencyID:currencyID, selector:selector}]);
  },


/**
 * Get Tap Points
 *
 * @param successCallback The success callback
 * @param failureCallback The error callback
 */
  getTapPoints : function(successCallback, failureCallback) {
  return cordova.exec(
                        successCallback,
                        failureCallback,
                        this.serviceName,
                        "getTapPoints",
                        []);
  },


/**
 * Spend Tap Points
 *
 * @param amount      Amount to spend.
 * @param successCallback The success callback
 * @param failureCallback The error callback
 */
  spendTapPoints : function(amount, successCallback, failureCallback) {
  return cordova.exec(
                        successCallback,
                        failureCallback,
                        this.serviceName,
                        "spendTapPoints",
                        [{amount:amount}]);
  },


/**
 * Award Tap Points
 *
 * @param amount      Amount to award.
 * @param successCallback The success callback
 * @param failureCallback The error callback
 */
  awardTapPoints : function(amount, successCallback, failureCallback) {
  return cordova.exec(
                        successCallback,
                        failureCallback,
                        this.serviceName,
                        "awardTapPoints",
                        [{amount:amount}]);
  },


/**
 * @deprecated Use getFullScreenAd instead.
 * Get Featured Ad
 *
 * @param successCallback The success callback
 * @param failureCallback The error callback
 */
  getFeaturedApp : function(successCallback, failureCallback) {
  return cordova.exec(
                        successCallback,
                        failureCallback,
                        this.serviceName,
                        "getFeaturedApp",
                        []);
  },


/**
 * @deprecated Use getFullScreenAdWithCurrencyID instead.
 * Get Featured Ad with a currency ID
 *
 * @param currencyID    The TapjoyConnect currencyID
 * @param successCallback The success callback
 * @param failureCallback The error callback
 */
  getFeaturedAppWithCurrencyID : function(currencyID, successCallback, failureCallback) {
  return cordova.exec(
                        successCallback,
                        failureCallback,
                        this.serviceName,
                        "getFeaturedAppWithCurrencyID",
                        [{currencyID:currencyID}]);
  },


/**
 * Sets the maximum number of times to display the same (unique) featured ad
 *
 * @param count       Maximum number of times to show the same featured ad unit
 * @param successCallback The success callback
 * @param failureCallback The error callback
 */
  setFeaturedAppDisplayCount : function(count, successCallback, failureCallback) {
  return cordova.exec(
                        successCallback,
                        failureCallback,
                        this.serviceName,
                        "setFeaturedAppDisplayCount",
                        [{count:count}]);
  },


/**
 * @deprecated Use showFullScreenAd instead.
 * Shows the featured ad.  Call after getting a success from getFeaturedApp(...)
 *
 * @param successCallback The success callback
 * @param failureCallback The error callback
 */
  showFeaturedAppFullScreenAd : function(successCallback, failureCallback) {
  return cordova.exec(
                        successCallback,
                        failureCallback,
                        this.serviceName,
                        "showFeaturedAppFullScreenAd",
                        []);
  },

/**
 * Get a Full Screen Ad.
 *
 * @param successCallback The success callback
 * @param failureCallback The error callback
 */
  getFullScreenAd : function(successCallback, failureCallback) {
  return cordova.exec(
                        successCallback,
                        failureCallback,
                        this.serviceName,
                        "getFullScreenAd",
                        []);
  },


/**
 * Get Full Screen Ad with a currency ID
 *
 * @param currencyID    The TapjoyConnect currencyID
 * @param successCallback The success callback
 * @param failureCallback The error callback
 */
  getFullScreenAdWithCurrencyID : function(currencyID, successCallback, failureCallback) {
  return cordova.exec(
                        successCallback,
                        failureCallback,
                        this.serviceName,
                        "getFullScreenAdWithCurrencyID",
                        [{currencyID:currencyID}]);
  },

/**
 * Shows the full screen ad.  Call after getting a success from getFullScreenAd(...)
 *
 * @param successCallback The success callback
 * @param failureCallback The error callback
 */
  showFullScreenAd : function(successCallback, failureCallback) {
  return cordova.exec(
                        successCallback,
                        failureCallback,
                        this.serviceName,
                        "showFullScreenAd",
                        []);
  },

/**
 * Get a Daily Reward.
 *
 * @param successCallback The success callback
 * @param failureCallback The error callback
 */
  getDailyRewardAd : function(successCallback, failureCallback) {
  return cordova.exec(
                         successCallback,
                         failureCallback,
                         this.serviceName,
                         "getDailyRewardAd",
                         []);
  },


/**
 * Get Daily Reward with a currency ID
 *
 * @param currencyID    The TapjoyConnect currencyID
 * @param successCallback The success callback
 * @param failureCallback The error callback
 */
  getDailyRewardAdWithCurrencyID : function(currencyID, successCallback, failureCallback) {
  return cordova.exec(
                         successCallback,
                         failureCallback,
                         this.serviceName,
                         "getDailyRewardAdWithCurrencyID",
                         [{currencyID:currencyID}]);
  },


/**
 * Shows the daily reward.  Call after getting a success from getDailyReward(...)
 *
 * @param successCallback The success callback
 * @param failureCallback The error callback
 */
  showDailyRewardAd : function(successCallback, failureCallback) {
  return cordova.exec(
                         successCallback,
                         failureCallback,
                         this.serviceName,
                         "showDailyRewardAd",
                         []);
  },

/**
 * Initializes video ads.  Call to have video ads available in the Marketplace.
 *
 * @param successCallback The success callback
 * @param failureCallback The error callback
 */
  initVideoAd : function(successCallback, failureCallback) {
  return cordova.exec(
                        successCallback,
                        failureCallback,
                        this.serviceName,
                        "initVideoAd",
                        []);
  },


/**
 * Sets the maximum number of videos to cache on the device.
 *
 * @param count       Number of videos to cache on the device.
 * @param successCallback The success callback
 * @param failureCallback The error callback
 */
  setVideoCacheCount : function(count, successCallback, failureCallback) {
  return cordova.exec(
                        successCallback,
                        failureCallback,
                        this.serviceName,
                        "setVideoCacheCount",
                        [{count:count}]);
  },

/**
 * Start caching videos (if allowed)
 *
 * @param successCallback The success callback
 * @param failureCallback The error callback
 */
  cacheVideos : function(successCallback, failureCallback) {
  return cordova.exec(
                        successCallback,
                        failureCallback,
                        this.serviceName,
                        "cacheVideos",
                        []);
  },

/**
 * Sets the video notifier
 *
 * @param successCallback The success callback
 * @param failureCallback The error callback
 */
  setVideoAdDelegate : function(successCallback, failureCallback) {
  return cordova.exec(
                         successCallback,
                         failureCallback,
                         this.serviceName,
                         "setVideoAdDelegate",
                         []);
  },

/**
 * Sends IAP event.
 *
 * @param name        Item name.
 * @param price       Item price (real life currency).
 * @param quantity      Quantity of the item purchased.
 * @param currencyCode    Real life currency code purchase was made in.
 * @param successCallback The success callback
 * @param failureCallback The error callback
 */
  sendIAPEvent : function(name, price, quantity, currencyCode, successCallback, failureCallback) {
  return cordova.exec(
                         successCallback,
                         failureCallback,
                         this.serviceName,
                         "sendIAPEvent",
                        [{name:name, price:price, quantity:quantity, currencyCode:currencyCode}]);
  },


/**
 * Get Display Ad
 *
 * @param successCallback The success callback
 * @param failureCallback The error callback
 */
  getDisplayAd : function(successCallback, failureCallback) {
  return cordova.exec(
                        successCallback,
                        failureCallback,
                        this.serviceName,
                        "getDisplayAd",
                        []);
  },

/**
 * Shows the Display Ad. Call after getting a success from getDisplayAd(...)
 *
 * @param successCallback The success callback
 * @param failureCallback The error callback
 */
  showDisplayAd : function(successCallback, failureCallback) {
  return cordova.exec(
                        successCallback,
                        failureCallback,
                        this.serviceName,
                        "showDisplayAd",
                        []);
  },

/**
 * Hides the Display Ad
 *
 * @param successCallback The success callback
 * @param failureCallback The error callback
 */
  hideDisplayAd : function(successCallback, failureCallback) {
  return cordova.exec(
                        successCallback,
                        failureCallback,
                        this.serviceName,
                        "hideDisplayAd",
                        []);
  },

/**
 * Enable auto-refresh of the display ad
 *
 * @param enable            Boolean to enable or disable auto-refresh
 * @param successCallback The success callback
 * @param failureCallback The error callback
 */
  enableDisplayAdAutoRefresh : function(enable, successCallback, failureCallback) {
  return cordova.exec(
                        successCallback,
                        failureCallback,
                        this.serviceName,
                        "enableDisplayAdAutoRefresh",
                        [{enable:enable}]);
  },

/**
 * Moves the location of the display ad
 *
 * @param x                 The x coordinate
 * @param y                 The y coordinate
 * @param successCallback The success callback
 * @param failureCallback The error callback
 */
  moveDisplayAd : function(x, y, successCallback, failureCallback) {
  return cordova.exec(
                        successCallback,
                        failureCallback,
                        this.serviceName,
                        "moveDisplayAd",
                        [{x:x, y:y}]);
  },

/**
 * Sets the Display ad size. Size value must be one of TapjoyConnect.TJC_DISPLAY_AD_SIZE_320X50, TapjoyConnect.TJC_DISPLAY_AD_SIZE_640X100, or TapjoyConnect.TJC_DISPLAY_AD_SIZE_768X90
 *
 * @param size              Display ad size
 * @param successCallback The success callback
 * @param failureCallback The error callback
 */
  setDisplayAdSize: function(size, successCallback, failureCallback) {
  return cordova.exec(
                        successCallback,
                        failureCallback,
                        this.serviceName,
                        "setDisplayAdSize",
                        [{size:size}]);
  }
}

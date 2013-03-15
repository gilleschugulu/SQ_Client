// Copyright (C) 2011-2012 by Tapjoy Inc.
//
// This file is part of the Tapjoy SDK.
//
// By using the Tapjoy SDK in your software, you agree to the terms of the Tapjoy SDK License Agreement.
//
// The Tapjoy SDK is bound by the Tapjoy SDK License Agreement and can be found here: https://www.tapjoy.com/sdk/license

var TapjoyConnect = {
  /**
   * Initialize Tapjoy Connect
   *
   * @param appID       The Tapjoy App ID.
   * @param secretKey     The Tapjoy Secret Key.
   * @param successCallback The success callback
   * @param failureCallback The error callback
   */
  requestTapjoyConnect : function(successCallback, failureCallback) {
    return Cordova.exec(
                  successCallback,
                  failureCallback,
                  "TapjoyConnect",
                  "requestTapjoyConnect",
                  []);
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
    return Cordova.exec(
                  successCallback,
                  failureCallback,
                  "TapjoyConnect",
                  "setUserID",
                  [userID]);
  },


  /**
   * Pay Per Action.
   *
   * @param actionID      PPA ID.
   * @param successCallback The success callback
   * @param failureCallback The error callback
   */
  actionComplete : function(actionID, successCallback, failureCallback) {
    return Cordova.exec(
                  successCallback,
                  failureCallback,
                  "TapjoyConnect",
                  "actionComplete",
                  [actionID]);
  },


  /**
   * Show Marketplace
   *
   * @param successCallback The success callback
   * @param failureCallback The error callback
   */
  showOffers : function(onCloseCallback, failureCallback) {
    return Cordova.exec(
                  onCloseCallback,
                  failureCallback,
                  "TapjoyConnect",
                  "showOffers",
                  []);
  },


  /**
   * Show Marketplace with a currency ID
   *
   * @param currencyID    The Tapjoy currency ID
   * @param selector      Whether to show the currency selector or not
   * @param successCallback The success callback
   * @param failureCallback The error callback
   */
  showOffersWithCurrencyID : function(currencyID, selector, onCloseCallback, failureCallback) {
    return Cordova.exec(
                  onCloseCallback,
                  failureCallback,
                  "TapjoyConnect",
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
    return Cordova.exec(
                  successCallback,
                  failureCallback,
                  "TapjoyConnect",
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
    return Cordova.exec(
                  successCallback,
                  failureCallback,
                  "TapjoyConnect",
                  "spendTapPoints",
                  [amount]);
  },


  /**
   * Award Tap Points
   *
   * @param amount      Amount to award.
   * @param successCallback The success callback
   * @param failureCallback The error callback
   */
  awardTapPoints : function(amount, successCallback, failureCallback) {
    return Cordova.exec(
                  successCallback,
                  failureCallback,
                  "TapjoyConnect",
                  "awardTapPoints",
                  [amount]);
  },


  /**
   * Get Featured Ad
   *
   * @param successCallback The success callback
   * @param failureCallback The error callback
   */
  getFeaturedApp : function(successCallback, failureCallback) {
    return Cordova.exec(
                  successCallback,
                  failureCallback,
                  "TapjoyConnect",
                  "getFeaturedApp",
                  []);
  },


  /**
   * Get Featured Ad with a currency ID
   *
   * @param currencyID    The Tapjoy currencyID
   * @param successCallback The success callback
   * @param failureCallback The error callback
   */
  getFeaturedAppWithCurrencyID : function(currencyID, successCallback, failureCallback) {
    return Cordova.exec(
                  successCallback,
                  failureCallback,
                  "TapjoyConnect",
                  "getFeaturedAppWithCurrencyID",
                  [currencyID]);
  },


  /**
   * Sets the maximum number of times to display the same (unique) featured ad
   *
   * @param count       Maximum number of times to show the same featured ad unit
   * @param successCallback The success callback
   * @param failureCallback The error callback
   */
  setFeaturedAppDisplayCount : function(count, successCallback, failureCallback) {
    return Cordova.exec(
                  successCallback,
                  failureCallback,
                  "TapjoyConnect",
                  "setFeaturedAppDisplayCount",
                  [count]);
  },


  /**
   * Shows the featured ad.  Call after getting a success from getFeaturedApp(...)
   *
   * @param successCallback The success callback
   * @param failureCallback The error callback
   */
  showFeaturedAppFullScreenAd : function(successCallback, failureCallback) {
    return Cordova.exec(
                  successCallback,
                  failureCallback,
                  "TapjoyConnect",
                  "showFeaturedAppFullScreenAd",
                  []);
  },


  /**
   * Initializes video ads.  Call to have video ads available in the Marketplace.
   *
   * @param successCallback The success callback
   * @param failureCallback The error callback
   */
  initVideoAd : function(successCallback, failureCallback) {
    return Cordova.exec(
                  successCallback,
                  failureCallback,
                  "TapjoyConnect",
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
    return Cordova.exec(
                  successCallback,
                  failureCallback,
                  "TapjoyConnect",
                  "setVideoCacheCount",
                  [count]);
  }
};

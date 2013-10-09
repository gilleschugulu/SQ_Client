var MKStoreError = {
  UNKNOWN_ERROR               : 0,   // Une erreur inconnue est survenue
  PURCHASE_CANCELLED          : 1,   //
  CANNOT_RUN_IN_SIMULATOR     : 2,   // Impossible de récupérer les produits dans le simulateur
  NO_INTERNET_CONNECTION      : 3,   // Vous devez etre connecté à internet
  MISSING_PRODUCTID           : 4,   // L'ID du produit est manquant
  PAYMENT_NOT_ALLOWED         : 5,   // Le paiement n'est pas autorisé
  PAYMENT_INVALID             : 6,   // Le paiement est invalide
  COULD_NOT_GET_PRODUCTS      : 7,   // Impossible de récupérer les produits
  COULD_NOT_RESTORE_PURCHASES : 8    // Impossible de restorer les achats
};

var MKStore = {
  gotProducts: false,

  getErrorName: function(errCode) {
    for (errName in MKStoreError)
      if (MKStoreError[errName] == errName)
        return errName;
    return null;
  },

  buyFeature: function(productID, success, fail, cancel, extra) {
    var errorCallback = function(error) {
      error.code === MKStoreError.PURCHASE_CANCELLED ? cancel() : fail(error);
    };
    Cordova.exec(success, errorCallback, "MKStore", "buyFeature", [productID, extra]);
  },

  getProducts: function(products, success, fail) {
    var self=this;
    var ok = function(params) {
      self.gotProducts = true;
      if (typeof success !== "undefined")
        success(params);
    }
    Cordova.exec(ok, fail, "MKStore", "getProducts", [{products:products}]);
  },

  restorePurchases: function(success, fail) {
    Cordova.exec(success, fail, "MKStore", "restorePurchases", []);
  }
};
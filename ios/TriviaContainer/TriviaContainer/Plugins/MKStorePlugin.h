//
//  MKStorePlugin.h
//  LesRestosDuCoeur
//
//  Created by Gilles Bellefontaine on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasePlugin.h"
#import "MKSKProduct.h"
#import "MKStoreManager.h"

typedef enum {
	MKStoreErrorCodeUnknownError            = 0,
	MKStoreErrorCodePurchaseCancelled       = 1,
	MKStoreErrorCodeCannotRunInSimulator    = 2,
	MKStoreErrorCodeNoInternetConnection    = 3,
	MKStoreErrorCodeMissingProductID        = 4,
	MKStoreErrorCodePaymentNotAllowed       = 5,
	MKStoreErrorCodePaymentInvalid          = 6,
	MKStoreErrorCodeCouldNotGetProducts     = 7,
    MKStoreErrorCodeCouldNotRestorePurchases= 8
} MKStoreErrorCode;

@interface MKStorePlugin : BasePlugin <MKStoreManagerDataSource> {
}

- (void) buyFeature:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) getProducts:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) restorePurchases:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end

//
//  MKStorePlugin.m
//  LesRestosDuCoeur
//
//  Created by Gilles Bellefontaine on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MKStorePlugin.h"
#import "CDVReachability.h"

NSString* const kMKStorePluginProductsKey           = @"products";
NSString* const kMKStorePluginConsumablesKey        = @"consumables";
NSString* const kMKStorePluginNonConsumablesKey     = @"nonConsumables";
NSString* const kMKStorePluginSubscriptionsKey      = @"subscriptions";
NSString* const kMKStorePluginConsumableNameKey     = @"name";
NSString* const kMKStorePluginConsumableQuantityKey = @"value";

@interface MKStorePlugin ()

@property (nonatomic, strong) CDVReachability* reachability;
@property (nonatomic, strong) NSString* requestProductDataCallbackID;
@property (nonatomic, strong) NSDictionary* customHTTPHeaders;
@property (nonatomic, strong) NSDictionary* customPOSTData;
@property (nonatomic, strong) NSDictionary* products;

- (void) onPurchaseComplete:(id)response callback:(NSString *)callbackID;
- (void) onPurchaseCancel:(NSError *)error callback:(NSString *)callbackID;
- (void) onPurchaseError:(NSError *)error callback:(NSString *)callbackID;

- (void) onFetchProductData;
- (void) sendProductsToCallback;

@end

@implementation MKStorePlugin

@synthesize requestProductDataCallbackID;
@synthesize reachability;
@synthesize customHTTPHeaders;
@synthesize customPOSTData;
@synthesize products;

- (CDVPlugin*) initWithWebView:(UIWebView *)theWebView {
    if ((self = [super initWithWebView:theWebView])) {
        self.requestProductDataCallbackID = nil;
        self.products = nil;
        self.reachability = [CDVReachability reachabilityForInternetConnection];
    }
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL) isNetworkAvailable {
    return [self.reachability currentReachabilityStatus] != NotReachable;
}

#pragma mark - Request Payment

- (void) buyFeature:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    NSString* buyFeatureCallbackID  = [arguments pop];
    NSString* feature               = [arguments objectAtIndex:0];
    self.customHTTPHeaders          = [options objectForKey:@"headers"];
    self.customPOSTData             = [options objectForKey:@"postData"];
    NSString* remoteProductServer   = [options objectForKey:@"remoteProductServer"];

    if (![self isNetworkAvailable]) {
        NSLog(@"Error:Not connected!");
        return [self sendErrorCode:MKStoreErrorCodeNoInternetConnection toCallback:buyFeatureCallbackID];
    }
    if (feature == nil) {
        NSLog(@"Error:missing product id!");
        return [self sendErrorCode:MKStoreErrorCodeMissingProductID toCallback:buyFeatureCallbackID];
    }
#if TARGET_IPHONE_SIMULATOR
    NSLog(@"WARNING : fake-buying %@ (on simulator)", feature);
    [self onPurchaseComplete:feature callback:buyFeatureCallbackID];
#else
    if (remoteProductServer)
        [MKStoreManager sharedManager].remoteProductServer = remoteProductServer;
    if (self.customHTTPHeaders != nil)
        [MKStoreManager sharedManager].customHTTPHeaders = ^(id body) {
            return self.customHTTPHeaders;
        };
    if (self.customPOSTData != nil)
        [MKStoreManager sharedManager].customReceiptPostData = ^(NSData* receipt) {
            NSMutableDictionary* data = [MKSKProduct receiptPostData:receipt];
            [data addEntriesFromDictionary:self.customPOSTData];
            return data;
        };
    [[MKStoreManager sharedManager] buyFeature:feature
                                    onComplete:^(id response)   {[self onPurchaseComplete:response callback:buyFeatureCallbackID];}
                                      onCancel:^(NSError* error){[self onPurchaseCancel:error callback:buyFeatureCallbackID];}
                                       onError:^(NSError* error){[self onPurchaseError:error callback:buyFeatureCallbackID];}];
#endif
}

#pragma mark - Event Request Payment

- (void) onPurchaseComplete:(id)response callback:(NSString *)callbackID {
    [self sendSuccessResult:response toCallback:callbackID];
}

- (void) onPurchaseCancel:(NSError *)error callback:(NSString *)callbackID {
    [self sendErrorCode:MKStoreErrorCodePurchaseCancelled toCallback:callbackID];
}

- (void) onPurchaseError:(NSError *)error callback:(NSString *)callbackID {
    if (error == nil || ![[error domain] isEqualToString:SKErrorDomain])
        return [self sendErrorCode:MKStoreErrorCodeUnknownError toCallback:callbackID];

    switch ([error code]) {
        case SKErrorPaymentNotAllowed://user is not allowed to authorize payments    
            [self sendErrorCode:MKStoreErrorCodePaymentNotAllowed toCallback:callbackID];
            break;
        case SKErrorClientInvalid://client is not allowed to perform the attempted action
        case SKErrorPaymentInvalid://payment parameters was not recognized by the Apple App Store
            [self sendErrorCode:MKStoreErrorCodePaymentInvalid toCallback:callbackID];
            break;
        case SKErrorPaymentCancelled://user cancelled a payment request
        case SKErrorUnknown:      //also appears when the user cancels the login
        default:
            // not connected, guess it was an error
            if (![self isNetworkAvailable])
                [self sendErrorCode:MKStoreErrorCodeNoInternetConnection toCallback:callbackID];        
            else
                [self sendErrorCode:MKStoreErrorCodeUnknownError toCallback:callbackID];                    
            break;
    }
}

#pragma mark - Request products data

- (void) getProducts:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    NSString* callbackID = [arguments pop];

    self.products = [options objectForKey:kMKStorePluginProductsKey];
#if TARGET_IPHONE_SIMULATOR
    NSLog(@"Error:Can't get products list on simulator!");
    [self sendErrorCode:MKStoreErrorCodeCannotRunInSimulator toCallback:callbackID];
#else
    if (![self isNetworkAvailable]) {
        NSLog(@"Error:Not connected!");
        return [self sendErrorCode:MKStoreErrorCodeNoInternetConnection toCallback:callbackID];
    }
    self.requestProductDataCallbackID = callbackID;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMKSKProductFetchedNotification object:nil];

    if ([[MKStoreManager sharedManager] areProductsAvailable]) // already have the products
        return [self sendProductsToCallback];

    NSLog(@"Waiting for products");
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onFetchProductData)
                                                 name:kMKSKProductFetchedNotification
                                               object:nil];
    [MKStoreManager sharedManager].dataSource = self;
    [[MKStoreManager sharedManager] requestProductData];
#endif
}

- (void) onFetchProductData {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMKSKProductFetchedNotification object:nil];
    [self sendProductsToCallback];
}

- (void) sendProductsToCallback
{
    NSMutableDictionary *dict = [[MKStoreManager sharedManager] pricesDictionary];
    if (dict != nil && [dict count] > 0)
        [self sendSuccessResult:dict toCallback:self.requestProductDataCallbackID];
    else {
        NSLog(@"Error:Can't get products list!");
        [self sendErrorCode:MKStoreErrorCodeCouldNotGetProducts toCallback:self.requestProductDataCallbackID];
    }
    self.requestProductDataCallbackID = nil;
}

#pragma mark - restore purchases

- (void) restorePurchases:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    NSString* restorePurchasesCallbackID = [arguments pop];
#if TARGET_IPHONE_SIMULATOR
    NSMutableDictionary* productsPrices = [[MKStoreManager sharedManager] pricesDictionary];
    NSLog(@"WARNING : unlocking everything (simulator):\n%@", productsPrices);
    if (productsPrices != nil)
        [self sendSuccessResult:[productsPrices allKeys] toCallback:restorePurchasesCallbackID];
    else
        [self sendErrorCode:MKStoreErrorCodeCouldNotGetProducts toCallback:restorePurchasesCallbackID];
#else
    [[MKStoreManager sharedManager] restorePreviousTransactionsOnComplete:^(SKPaymentQueue* queue) {
                                                                    NSMutableArray* restoredProductIds = [[NSMutableArray alloc] initWithCapacity:[queue.transactions count]];
                                                                    for (SKPaymentTransaction* transaction in queue.transactions)
                                                                        [restoredProductIds addObject:transaction.payment.productIdentifier];
                                                                    [self sendSuccessResult:restoredProductIds toCallback:restorePurchasesCallbackID];
                                                                } onError:^(SKPaymentQueue* queue, NSError* error) {
                                                                    [self sendErrorCode:MKStoreErrorCodeCouldNotRestorePurchases toCallback:restorePurchasesCallbackID];
                                                                }];
#endif
}

#pragma mark - <MKStoreManagerDataSource>

- (NSDictionary*) consumableProducts
{
    return [self.products objectForKey:kMKStorePluginConsumablesKey];
}

- (NSDictionary*) nonConsumableProducts
{
    return [self.products objectForKey:kMKStorePluginNonConsumablesKey];
}

- (NSDictionary*) subscriptionProducts
{
    return [self.products objectForKey:kMKStorePluginSubscriptionsKey];
}

- (NSString*) nameForConsumable:(id)consumable
{
    return [(NSDictionary*)consumable objectForKey:kMKStorePluginConsumableNameKey];
}

- (NSInteger) quantityForConsumable:(id)consumable
{
    return [[(NSDictionary*)consumable objectForKey:kMKStorePluginConsumableQuantityKey] integerValue];
}

@end

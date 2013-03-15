//
//  GoogleAnalyticsPlugin.m
//  Google Analytics plugin for PhoneGap
//
//  Created by Jesse MacFadyen on 11-04-21.
//  Updated to 1.x by Olivier Louvignes on 11-11-24.
//  Updated to 1.5 by Chris Kihneman on 12-04-09.
//  MIT Licensed
//

#import "GoogleAnalyticsPlugin.h"

// Dispatch period in seconds
static const NSInteger kGANDispatchPeriodSec = 10;

@implementation GoogleAnalyticsPlugin

- (void) startTrackerWithAccountID:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	[[GANTracker sharedTracker] startTrackerWithAccountID:[options objectForKey:@"accountId"]
										   dispatchPeriod:kGANDispatchPeriodSec
												 delegate:self];
}

- (void) trackEvent:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	NSString* category  = [options valueForKey:@"category"];
	NSString* action    = [options valueForKey:@"action"];
	NSString* label     = [options valueForKey:@"label"];
	NSInteger value     = [[options valueForKey:@"value"] integerValue];

	NSError *error      = nil;

	if (![[GANTracker sharedTracker] trackEvent:category
										 action:action
										  label:label
										  value:value
									  withError:&error]) {
		// Handle error here
		NSLog(@"GoogleAnalytics.trackEvent Error::%@", [error localizedDescription]);
	}

	NSLog(@"GoogleAnalytics.trackEvent::%@, %@, %@, %d", category, action, label, value);
}


- (void) trackTransaction:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    NSString* orderId   = [options objectForKey:@"orderId"];

    if (![[GANTracker sharedTracker] addTransaction:orderId
                                         totalPrice:[(NSNumber *)[options objectForKey:@"totalPrice"] doubleValue]
                                          storeName:[options objectForKey:@"storeName"]
                                           totalTax:[(NSNumber *)[options objectForKey:@"totalTax"] doubleValue]
                                       shippingCost:[(NSNumber *)[options objectForKey:@"shippingCost"] doubleValue]
                                          withError:nil])
        return;

    BOOL success = NO;
    for (NSDictionary* item in [options objectForKey:@"items"]) {
        success |= [[GANTracker sharedTracker] addItem:orderId
                                               itemSKU:[item objectForKey:@"SKU"]
                                             itemPrice:[(NSNumber *)[options objectForKey:@"price"] doubleValue]
                                             itemCount:[(NSNumber *)[options objectForKey:@"quantity"] doubleValue]
                                              itemName:[options objectForKey:@"name"]
                                          itemCategory:[options objectForKey:@"category"]
                                             withError:nil];
    }
    if (success)
        [[GANTracker sharedTracker] trackTransactions:nil];
    else
        [[GANTracker sharedTracker] clearTransactions:nil];
}

- (void) setCustomVariable:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	NSUInteger index    = [[options valueForKey:@"index"] unsignedIntegerValue];
	NSString* name      = [options valueForKey:@"name"];
	NSString* value     = [options valueForKey:@"value"];

	NSError *error      = nil;

	if (![[GANTracker sharedTracker] setCustomVariableAtIndex:index
                                                         name:name
                                                        value:value
                                                    withError:&error]) {
		// Handle error here
		NSLog(@"GoogleAnalyticsPlugin.setCustonVariable Error::%@",[error localizedDescription]);
	}

	NSLog(@"GoogleAnalyticsPlugin.setCustomVariable::%d, %@, %@", index, name, value);
}

- (void) trackPageview:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	[[GANTracker sharedTracker] trackPageview:[options objectForKey:@"pageUri"]
                                    withError:nil];
}

- (void) hitDispatched:(NSString *)hitString
{
//	NSString* callback = [NSString stringWithFormat:@"GoogleAnalytics.hitDispatched(%@);", hitString];
//	[self.webView stringByEvaluatingJavaScriptFromString:callback];
}

- (void) trackerDispatchDidComplete:(GANTracker *)tracker
                   eventsDispatched:(NSUInteger)hitsDispatched
               eventsFailedDispatch:(NSUInteger)hitsFailedDispatch
{
//	NSString* callback = [NSString stringWithFormat:@"GoogleAnalytics.trackerDispatchDidComplete(%d);", hitsDispatched];
//	[self.webView stringByEvaluatingJavaScriptFromString:callback];
}

- (void) dealloc
{
	[[GANTracker sharedTracker] stopTracker];
}

@end

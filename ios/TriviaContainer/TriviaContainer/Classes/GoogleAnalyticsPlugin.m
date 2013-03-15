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

@interface GoogleAnalyticsPlugin ()

@property (strong) NSMutableArray* trackers;

@end

@implementation GoogleAnalyticsPlugin

@synthesize trackers;

- (void) startTrackerWithAccountID:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    // Optional: automatically track uncaught exceptions with Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    // Optional: set debug to YES for extra debugging information.
    //    [GAI sharedInstance].debug = YES;
    // Create tracker instance.
    NSArray* accountIDs = [options objectForKey:@"accountIds"];
    if ([accountIDs count] < 1)
        return;
    self.trackers = [[NSMutableArray alloc] initWithCapacity:[accountIDs count]];
    for (NSString* accountID in accountIDs) {
        id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:accountID];
        [self.trackers addObject:tracker];
    }
    [GAI sharedInstance].defaultTracker = [self.trackers objectAtIndex:0];
}

- (void) trackEvent:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    if (self.trackers == nil)
        return;
	NSString* category  = [options valueForKey:@"category"];
	NSString* action    = [options valueForKey:@"action"];
	NSString* label     = [options valueForKey:@"label"];
	NSNumber* value     = @([[options valueForKey:@"value"] integerValue]);

    for (id<GAITracker> tracker in self.trackers)
        [tracker trackEventWithCategory:category
                             withAction:action
                              withLabel:label
                              withValue:value];

	NSLog(@"GoogleAnalytics.trackEvent::%@, %@, %@, %@", category, action, label, value);
}

- (void) trackTransaction:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    if (self.trackers == nil)
        return;

    NSString* orderId       = [options objectForKey:@"orderId"];
    NSString* affiliation   = [options objectForKey:@"affiliation"];

    GAITransaction* transaction = [GAITransaction transactionWithId:orderId withAffiliation:affiliation];

    for (NSDictionary* item in [options objectForKey:@"items"])
        [transaction addItemWithCode:[item objectForKey:@"SKU"]
                                name:[options objectForKey:@"name"]
                            category:[options objectForKey:@"category"]
                         priceMicros:[(NSNumber *)[options objectForKey:@"price"] doubleValue]
                            quantity:[[options objectForKey:@"quantity"] integerValue]];

    for (id<GAITracker> tracker in self.trackers)
        [tracker trackTransaction:transaction];
}

- (void) trackPageview:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    if (self.trackers == nil)
        return;
    for (id<GAITracker> tracker in self.trackers)
        [tracker trackView:[options objectForKey:@"pageUri"]];
}

@end

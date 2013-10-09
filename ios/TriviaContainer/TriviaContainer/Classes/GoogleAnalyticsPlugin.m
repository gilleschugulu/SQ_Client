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
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

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
    [[GAI sharedInstance].logger setLogLevel:kGAILogLevelVerbose];
//    [GAI sharedInstance].dryRun = YES;
    // Create tracker instance.
    NSArray* accountIDs = [options objectForKey:@"accountIds"];
    if ([accountIDs count] < 1)
        return;
    self.trackers = [[NSMutableArray alloc] initWithCapacity:[accountIDs count]];
    for (NSString* accountID in accountIDs) {
        id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:accountID];
        [self.trackers addObject:tracker];
    }
    [GAI sharedInstance].defaultTracker = self.trackers[0];
}

- (void) trackEvent:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    if (self.trackers == nil)
        return;
	NSString* category  = [options valueForKey:@"category"];
	NSString* action    = [options valueForKey:@"action"];
	NSString* label     = [options valueForKey:@"label"];
	NSNumber* value     = @([[options valueForKey:@"value"] integerValue]);


    for (id<GAITracker> tracker in self.trackers) {
        GAIDictionaryBuilder* db = [GAIDictionaryBuilder createEventWithCategory:category
                                                                          action:action
                                                                           label:label
                                                                           value:value];
        [tracker send:[db build]];
    }
	NSLog(@"GoogleAnalytics.trackEvent::%@, %@, %@, %@", category, action, label, value);
}

- (void) trackTransaction:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    if (self.trackers == nil)
        return;

    NSLog(@"omg %@", options);
    NSDictionary* transaction = options[@"transaction"];
    if ([transaction[@"revenue"] isKindOfClass:[NSNumber class]])
        NSLog(@"OMG NS NUMBER");
    else
        NSLog(@"NOT NS NUMBER LOL");
    GAIDictionaryBuilder* transactionDB = [GAIDictionaryBuilder createTransactionWithId:transaction[@"id"]
                                                                            affiliation:transaction[@"affiliation"]
                                                                                revenue:transaction[@"revenue"]
                                                                                    tax:transaction[@"tax"]
                                                                               shipping:transaction[@"shipping"]
                                                                           currencyCode:transaction[@"currency"]];

    NSMutableArray* itemDBs = [NSMutableArray arrayWithCapacity:[options[@"items"] count]];
    for (NSDictionary* item in options[@"items"]) {
        GAIDictionaryBuilder* itemDB = [GAIDictionaryBuilder createItemWithTransactionId:transaction[@"id"]
                                                                                    name:item[@"name"]
                                                                                     sku:item[@"sku"]
                                                                                category:item[@"category"]
                                                                                   price:item[@"price"]
                                                                                quantity:item[@"quantity"]
                                                                            currencyCode:item[@"currency"]];
        [itemDBs addObject:itemDB];
    }

    for (id<GAITracker> tracker in self.trackers) {
        [tracker send:[transactionDB build]];
        for (GAIDictionaryBuilder *itemDB in itemDBs)
            [tracker send:[itemDB build]];
    }
}

- (void) trackPageview:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    if (self.trackers == nil)
        return;
    for (id<GAITracker> tracker in self.trackers) {
        [tracker set:kGAIScreenName value:options[@"pageUri"]];
        [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    }
}

@end

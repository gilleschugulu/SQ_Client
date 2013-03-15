//
//  TapjoyConnectPlugin.m
//  TriviaStars
//
//  Created by Sergio Kunats on 9/5/12.
//  Copyright (c) 2012 Chugulu. All rights reserved.
//

#import "TapjoyConnectPlugin.h"

@implementation TapjoyConnectPlugin


@synthesize connectCallbackID, featuredAppCallbackID, tapPointsCallbackID, spendTapPointsCallbackID, awardTapPointsCallbackID, offersCallbackID;

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)requestTapjoyConnect:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:TJC_CONNECT_SUCCESS object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:TJC_CONNECT_FAILED object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:TJC_FEATURED_APP_RESPONSE_NOTIFICATION object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:TJC_TAP_POINTS_RESPONSE_NOTIFICATION object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:TJC_SPEND_TAP_POINTS_RESPONSE_NOTIFICATION object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:TJC_AWARD_TAP_POINTS_RESPONSE_NOTIFICATION object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:TJC_TAP_POINTS_RESPONSE_NOTIFICATION_ERROR object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:TJC_SPEND_TAP_POINTS_RESPONSE_NOTIFICATION_ERROR object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:TJC_AWARD_TAP_POINTS_RESPONSE_NOTIFICATION_ERROR object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TJC_VIEW_CLOSED_NOTIFICATION object:nil];


	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tjcConnectSuccess:) name:TJC_CONNECT_SUCCESS object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tjcConnectFail:) name:TJC_CONNECT_FAILED object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFullScreenAd:)
                                                 name:TJC_FEATURED_APP_RESPONSE_NOTIFICATION
                                               object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getUpdatedPoints:)
                                                 name:TJC_TAP_POINTS_RESPONSE_NOTIFICATION
                                               object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(spendUpdatedPoints:)
                                                 name:TJC_SPEND_TAP_POINTS_RESPONSE_NOTIFICATION
                                               object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(awardUpdatedPoints:)
                                                 name:TJC_AWARD_TAP_POINTS_RESPONSE_NOTIFICATION
                                               object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getUpdatedPointsError:)
                                                 name:TJC_TAP_POINTS_RESPONSE_NOTIFICATION_ERROR
                                               object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(spendUpdatedPointsError:)
                                                 name:TJC_SPEND_TAP_POINTS_RESPONSE_NOTIFICATION_ERROR
                                               object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(awardUpdatedPointsError:)
                                                 name:TJC_AWARD_TAP_POINTS_RESPONSE_NOTIFICATION_ERROR
                                               object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(offersViewDidClose:)
                                                 name:TJC_VIEW_CLOSED_NOTIFICATION
                                               object:nil];

	self.connectCallbackID = [arguments pop];

	[TapjoyConnect setPlugin:@"phonegap"];
	[TapjoyConnect requestTapjoyConnect:TapjoyAppID secretKey:TapjoyAppSecretKey];
}


- (void)setUserID:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	NSString *userID = [arguments objectAtIndex:1];

	[TapjoyConnect setUserID:userID];
}


- (void)actionComplete:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	NSString *actionID = [arguments objectAtIndex:1];

	[TapjoyConnect actionComplete:actionID];
}


- (void)showOffers:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    self.offersCallbackID = [arguments objectAtIndex:0];
    [TapjoyConnect showOffersWithViewController:self.viewController];
}


- (void)showOffersWithCurrencyID:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    self.offersCallbackID = [arguments objectAtIndex:0];
	NSString *currencyID = [options objectForKey:@"currencyID"];
	id selector = [options objectForKey:@"selector"];
	BOOL selectorBool = [selector boolValue];

	[TapjoyConnect showOffersWithCurrencyID:currencyID withViewController:self.viewController withCurrencySelector:selectorBool];
}


- (void)getTapPoints:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	self.tapPointsCallbackID = [arguments pop];

	NSLog(@"tap points callback ID: %@", self.tapPointsCallbackID);

	[TapjoyConnect getTapPoints];
}


- (void)spendTapPoints:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	self.spendTapPointsCallbackID = [arguments pop];

	NSString *amountString = [arguments objectAtIndex:0];
	int amount = [amountString intValue];

	[TapjoyConnect spendTapPoints:amount];
}


- (void)awardTapPoints:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	self.awardTapPointsCallbackID = [arguments pop];

	NSString *amountString = [arguments objectAtIndex:0];
	int amount = [amountString intValue];

	[TapjoyConnect awardTapPoints:amount];
}



- (void)getFullScreenAd:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	self.featuredAppCallbackID = [arguments pop];

	[TapjoyConnect getFullScreenAd];
}


- (void)getFullScreenAdWithCurrencyID:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	self.featuredAppCallbackID = [arguments pop];

	NSString *currencyID = [arguments objectAtIndex:0];

	[TapjoyConnect getFullScreenAdWithCurrencyID:currencyID];
}


- (void)showFullScreenAd:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	[TapjoyConnect showFullScreenAd];
}


- (void)initVideoAd:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	[TapjoyConnect cacheVideosWithDelegate:self];
}


- (void)setVideoCacheCount:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	NSString *displayCountString = [arguments objectAtIndex:1];
	int displayCount = [displayCountString intValue];

	[TapjoyConnect setVideoCacheCount:displayCount];
}










- (void)offersViewDidClose:(NSNotification*)notifyObj
{
    if (self.offersCallbackID)
        [self sendSuccessResult:nil toCallback:self.offersCallbackID];
}

- (void)getUpdatedPoints:(NSNotification*)notifyObj
{
	NSNumber *tapPoints = notifyObj.object;
	NSString *tapPointsStr = [NSString stringWithFormat:@"Tap Points: %d", [tapPoints intValue]];
	NSLog(@"%@", tapPointsStr);

	NSString *stringToReturn = [NSString stringWithFormat:@"Tap Points: %d", [tapPoints intValue]];

	CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                      messageAsString:stringToReturn];

	NSLog(@"tap points callback ID: %@", self.tapPointsCallbackID);

	[self writeJavascript:[pluginResult toSuccessCallbackString:self.tapPointsCallbackID]];
}


- (void)getUpdatedPointsError:(NSNotification*)notifyObj
{
	NSLog(@"Tap Points error");

	NSString *stringToReturn = @"Get Tap Points Failed";

	CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                      messageAsString:stringToReturn];

	[self writeJavascript:[pluginResult toErrorCallbackString:self.tapPointsCallbackID]];
}


- (void)spendUpdatedPoints:(NSNotification*)notifyObj
{
	NSNumber *tapPoints = notifyObj.object;
	NSString *tapPointsStr = [NSString stringWithFormat:@"Tap Points: %d", [tapPoints intValue]];
	NSLog(@"%@", tapPointsStr);

	NSString *stringToReturn = [NSString stringWithFormat:@"Tap Points: %d", [tapPoints intValue]];

	CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                      messageAsString:stringToReturn];

	[self writeJavascript:[pluginResult toSuccessCallbackString:self.spendTapPointsCallbackID]];
}


- (void)spendUpdatedPointsError:(NSNotification*)notifyObj
{
	NSLog(@"Spend Tap Points error");

	NSString *stringToReturn = @"Spend Tap Points Failed";

	CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                      messageAsString:stringToReturn];

	[self writeJavascript:[pluginResult toErrorCallbackString:self.spendTapPointsCallbackID]];
}


- (void)awardUpdatedPoints:(NSNotification*)notifyObj
{
	NSNumber *tapPoints = notifyObj.object;
	NSString *tapPointsStr = [NSString stringWithFormat:@"Tap Points: %d", [tapPoints intValue]];
	NSLog(@"%@", tapPointsStr);

	NSString *stringToReturn = [NSString stringWithFormat:@"Tap Points: %d", [tapPoints intValue]];

	CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                      messageAsString:stringToReturn];

	[self writeJavascript:[pluginResult toSuccessCallbackString:self.awardTapPointsCallbackID]];
}


- (void)awardUpdatedPointsError:(NSNotification*)notifyObj
{
	NSLog(@"Spend Tap Points error");

	NSString *stringToReturn = @"Award Tap Points Failed";

	CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                      messageAsString:stringToReturn];

	[self writeJavascript:[pluginResult toErrorCallbackString:self.awardTapPointsCallbackID]];
}


- (void)getFullScreenAd:(NSNotification*)notifyObj
{
	// notifyObj will be returned as Nil in case of internet error or unavailibity of featured App
	// or its Max Number of count has exceeded its limit
//	TJCFeaturedAppModel *featuredApp = notifyObj.object;
//	NSLog(@"Featured App Name: %@, Cost: %@, Description: %@, Amount: %d", featuredApp.name, featuredApp.cost, featuredApp.description, featuredApp.amount);
//	NSLog(@"Featured App Image URL %@ ", featuredApp.iconURL);
//
//	NSString *stringToReturn = @"Featured App Successful";
//
//	CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
//                                                      messageAsString:stringToReturn];
//	
//	[self writeJavascript:[pluginResult toSuccessCallbackString:self.featuredAppCallbackID]];
}


- (void)tjcConnectSuccess:(NSNotification*)notifyObj
{
	NSLog(@"Tapjoy connect Succeeded");
	
	NSString *stringToReturn = @"Connect Successful";
	
	CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK 
                                                      messageAsString:stringToReturn];
	
	[self writeJavascript:[pluginResult toSuccessCallbackString:self.connectCallbackID]];
}


- (void)tjcConnectFail:(NSNotification*)notifyObj
{
	NSLog(@"Tapjoy connect Failed");	
	
	NSString *stringToReturn = @"Connect Failed";
	
	CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK 
                                                      messageAsString:stringToReturn];
	
	[self writeJavascript:[pluginResult toErrorCallbackString:self.connectCallbackID]];
}

#pragma mark - <TJCVideoAdDelegate>

// Called when the video ad begins playing.
- (void)videoAdBegan {

}

// Called when the video ad is closed.
- (void)videoAdClosed {

}

@end

//
//  TapjoyConnectPlugin.m
//  TriviaStars
//
//  Created by Sergio Kunats on 9/5/12.
//  Copyright (c) 2012 Chugulu. All rights reserved.
//

#import "TapjoyConnectPlugin.h"

@implementation TapjoyConnectPlugin

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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TJC_FULL_SCREEN_AD_RESPONSE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TJC_DAILY_REWARD_RESPONSE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TJC_VIEW_CLOSED_NOTIFICATION object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:TJC_TAP_POINTS_RESPONSE_NOTIFICATION_ERROR object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:TJC_SPEND_TAP_POINTS_RESPONSE_NOTIFICATION_ERROR object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:TJC_AWARD_TAP_POINTS_RESPONSE_NOTIFICATION_ERROR object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TJC_FULL_SCREEN_AD_RESPONSE_NOTIFICATION_ERROR object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TJC_DAILY_REWARD_RESPONSE_NOTIFICATION_ERROR object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TJC_OFFERS_RESPONSE_NOTIFICATION_ERROR object:nil];


	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tjcConnectSuccess:) name:TJC_CONNECT_SUCCESS object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tjcConnectFail:) name:TJC_CONNECT_FAILED object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFeaturedApp:)
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFullScreenAd:)
                                                 name:TJC_FULL_SCREEN_AD_RESPONSE_NOTIFICATION
                                               object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDailyRewardAd:)
                                                 name:TJC_DAILY_REWARD_RESPONSE_NOTIFICATION
                                               object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(offerViewClosed:)
                                                 name:TJC_VIEW_CLOSED_NOTIFICATION
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
                                             selector:@selector(getFullScreenAdError:)
                                                 name:TJC_FULL_SCREEN_AD_RESPONSE_NOTIFICATION_ERROR
                                               object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getDailyRewardAdError:)
                                                 name:TJC_DAILY_REWARD_RESPONSE_NOTIFICATION_ERROR
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showOffersError:)
                                                 name:TJC_OFFERS_RESPONSE_NOTIFICATION_ERROR
                                               object:nil];
	self.connectCallbackID = [arguments pop];

	NSString *appID = TapjoyAppID;
	NSString *secretKey = TapjoyAppSecretKey;

    _displayAdSize = TJC_DISPLAY_AD_SIZE_320X50;
    _displayAdFrame = CGRectMake(0, 0, 320, 50);

	[TapjoyConnect setPlugin:@"phonegap"];

    if([self hasKeyFlag]){
        [TapjoyConnect requestTapjoyConnect:appID secretKey:secretKey options:_keyFlagValueDict];
    }
    else{
        [TapjoyConnect requestTapjoyConnect:appID secretKey:secretKey];
    }
}

- (BOOL)hasKeyFlag
{
    if (_keyFlagValueDict)
        return YES;
	return NO;
}

- (void)setFlagKeyValue:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
{
	if (!_keyFlagValueDict)
		_keyFlagValueDict = [[NSMutableDictionary alloc] init];
	[_keyFlagValueDict setObject:options[@"value"] forKey:options[@"key"]];

}

- (void)setUserID:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	NSString *userID = options[@"userID"];

	[TapjoyConnect setUserID:userID];
}


- (void)actionComplete:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	NSString *actionID = options[@"actionID"];

	[TapjoyConnect actionComplete:actionID];
}

- (void)showOffers:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    self.offersCallbackID = [arguments pop];
	[TapjoyConnect showOffersWithViewController:self.viewController];
}


- (void)showOffersWithCurrencyID:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    self.offersCallbackID = [arguments pop];
	NSString *currencyID = options[@"currencyID"];
	id selector = options[@"selector"];
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

	NSString *amountString = options[@"amount"];
	int amount = [amountString intValue];

	[TapjoyConnect spendTapPoints:amount];
}


- (void)awardTapPoints:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	self.awardTapPointsCallbackID = [arguments pop];

	NSString *amountString = options[@"amount"];
	int amount = [amountString intValue];

	[TapjoyConnect awardTapPoints:amount];
}



- (void)getFeaturedApp:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	self.featuredAppCallbackID = [arguments pop];

	[TapjoyConnect getFeaturedApp];
}


- (void)getFeaturedAppWithCurrencyID:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	self.featuredAppCallbackID = [arguments pop];

	NSString *currencyID = options[@"currencyID"];

	[TapjoyConnect getFeaturedAppWithCurrencyID:currencyID];
}


- (void)setFeaturedAppDisplayCount:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	NSString *displayCountString = [arguments objectAtIndex:1];
	int displayCount = [displayCountString intValue];

	[TapjoyConnect setFeaturedAppDisplayCount:displayCount];
}


- (void)showFeaturedAppFullScreenAd:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	[TapjoyConnect showFeaturedAppFullScreenAd];
}


- (void)initVideoAd:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	[TapjoyConnect initVideoAdWithDelegate:self];
}


- (void)setVideoCacheCount:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	NSString *displayCountString = options[@"count"];
	int displayCount = [displayCountString intValue];

	[TapjoyConnect setVideoCacheCount:displayCount];
}

- (void)getFullScreenAd:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    self.fullScreenAdCallbackID = [arguments pop];

	[TapjoyConnect getFullScreenAd];
}

- (void)getFullScreenAdWithCurrencyID:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    self.fullScreenAdCallbackID = [arguments pop];

	NSString *currencyID = options[@"currencyID"];

	[TapjoyConnect getFullScreenAdWithCurrencyID:currencyID];
}

- (void)showFullScreenAd:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    [TapjoyConnect showFullScreenAd];
}

- (void)getDailyRewardAd:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    self.dailyRewardAdCallbackID = [arguments pop];

    [TapjoyConnect getDailyRewardAd];
}

- (void)getDailyRewardAdWithCurrencyID:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    self.dailyRewardAdCallbackID = [arguments pop];

	NSString *currencyID = options[@"currencyID"];

    [TapjoyConnect getDailyRewardAdWithCurrencyID:currencyID];

}

- (void)showDailyRewardAd:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    [TapjoyConnect showDailyRewardAd];
}

- (void)cacheVideos:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    [TapjoyConnect cacheVideosWithDelegate:self];
}

- (void)setVideoAdDelegate:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options
{
    self.videoAdDelegateCallbackID = [arguments pop];
    [TapjoyConnect setVideoAdDelegate:self];
}

- (void)sendIAPEvent:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    NSString *name = options[@"name"];
    NSString *price = options[@"price"];
    NSString *quantity = options[@"quantity"];
    NSString *currencyCode = options[@"currencyCode"];

    [TapjoyConnect sendIAPEvent:name price:[price floatValue] quantity:[quantity intValue] currencyCode:currencyCode];
}

- (void)getDisplayAd:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    self.displayAdCallbackID = [arguments pop];

    [TapjoyConnect getDisplayAdWithDelegate:self];
}

- (void)showDisplayAd:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    TJCAdView *adView = [TapjoyConnect getDisplayAdView];
    [adView setFrame:_displayAdFrame];
    [self.viewController.view addSubview:(UIView *)adView];
}

- (void)hideDisplayAd:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    UIView *adView = (UIView*)[TapjoyConnect getDisplayAdView];

	[adView removeFromSuperview];
}

- (void)enableDisplayAdAutoRefresh:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    _enableDisplayAdAutoRefresh = options[@"enable"] != nil;
}

- (void)moveDisplayAd:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    // adjust frame
    NSString* xString = options[@"x"];
    NSString* yString = options[@"y"];
    _displayAdFrame.origin = CGPointMake([xString intValue], [yString intValue]);

    // move view
    TJCAdView *adView = [TapjoyConnect getDisplayAdView];
    [adView setFrame:_displayAdFrame];
}

- (void)setDisplayAdSize:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    _displayAdSize = options[@"size"];
}

- (void)getUpdatedPoints:(NSNotification*)notifyObj
{
	NSNumber *tapPoints = notifyObj.object;
	NSString *tapPointsStr = [NSString stringWithFormat:@"Tap Points: %d", [tapPoints intValue]];
	NSLog(@"%@", tapPointsStr);

	CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                         messageAsInt:[tapPoints intValue]];

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

	CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                         messageAsInt:[tapPoints intValue]];

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

	CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                         messageAsInt:[tapPoints intValue]];

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


- (void)getFeaturedApp:(NSNotification*)notifyObj
{
    // TODO: fix these lines
	// notifyObj will be returned as Nil in case of internet error or unavailibity of featured App
	// or its Max Number of count has exceeded its limit
    //	TJCFeaturedAppModel *featuredApp = notifyObj.object;
    //	NSLog(@"Featured App Name: %@, Cost: %@, Description: %@, Amount: %d", featuredApp.name, featuredApp.cost, featuredApp.description, featuredApp.amount);
    //	NSLog(@"Featured App Image URL %@ ", featuredApp.iconURL);

	NSString *stringToReturn = @"Featured App Successful";

	CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                      messageAsString:stringToReturn];

	[self writeJavascript:[pluginResult toSuccessCallbackString:self.featuredAppCallbackID]];
}

- (void)getFullScreenAd:(NSNotification*)notifyObj
{
	NSString *stringToReturn = @"Full Screen Ad Successful";

	CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                      messageAsString:stringToReturn];

	[self writeJavascript:[pluginResult toSuccessCallbackString:self.fullScreenAdCallbackID]];
}

- (void)getFullScreenAdError:(NSNotification*)notifyObj
{
	NSString *stringToReturn = @"Full Screen Ad Failed";

	CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                      messageAsString:stringToReturn];

	[self writeJavascript:[pluginResult toErrorCallbackString:self.fullScreenAdCallbackID]];
}

- (void)getDailyRewardAd:(NSNotification*)notifyObj
{

	NSString *stringToReturn = @"Daily Reward Ad Successful";

	CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                      messageAsString:stringToReturn];

	[self writeJavascript:[pluginResult toSuccessCallbackString:self.dailyRewardAdCallbackID]];
}

- (void)offerViewClosed:(NSNotification*)notifyObj
{
	CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];

	[self writeJavascript:[pluginResult toSuccessCallbackString:self.offersCallbackID]];
}

- (void)getDailyRewardAdError:(NSNotification*)notifyObj
{
    NSString *stringToReturn = @"Daily Reward Ad Failed";

	CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                      messageAsString:stringToReturn];

	[self writeJavascript:[pluginResult toErrorCallbackString:self.dailyRewardAdCallbackID]];

}

- (void)showOffersError:(NSNotification*)notifyObj
{
    NSString *stringToReturn = @"Show Offers Failed";

	CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                      messageAsString:stringToReturn];

	[self writeJavascript:[pluginResult toErrorCallbackString:self.offersCallbackID]];
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

#pragma mark Tapjoy Video Ads Delegate Methods

- (void)videoAdBegan
{
    NSString *stringToReturn = @"Video Ad Began";

	CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                      messageAsString:stringToReturn];

	[self writeJavascript:[pluginResult toSuccessCallbackString:self.videoAdDelegateCallbackID]];
}


- (void)videoAdClosed
{
    NSString *stringToReturn = @"Video Ad Closed";

	CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                      messageAsString:stringToReturn];

	[self writeJavascript:[pluginResult toSuccessCallbackString:self.videoAdDelegateCallbackID]];
}

- (void)videoAdError:(NSString *)errorMsg
{
    NSString *stringToReturn = @"Video Ad Error";

	CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                      messageAsString:stringToReturn];

	[self writeJavascript:[pluginResult toErrorCallbackString:self.videoAdDelegateCallbackID]];
}




#pragma mark Tapjoy Display Ads Delegate Methods

- (void)didReceiveAd:(TJCAdView*)adView
{
    NSString *stringToReturn = @"Display Ad Successful";

	CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                      messageAsString:stringToReturn];

	[self writeJavascript:[pluginResult toSuccessCallbackString:self.displayAdCallbackID]];
}


- (void)didFailWithMessage:(NSString*)msg
{
    NSString *stringToReturn = @"Display Ad Error";

	CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                      messageAsString:stringToReturn];
	
	[self writeJavascript:[pluginResult toErrorCallbackString:self.displayAdCallbackID]];
}


- (NSString*)adContentSize
{
	return _displayAdSize;
}

- (BOOL)shouldRefreshAd
{
    return [self shouldDisplayAdAutoRefresh];
}

@end

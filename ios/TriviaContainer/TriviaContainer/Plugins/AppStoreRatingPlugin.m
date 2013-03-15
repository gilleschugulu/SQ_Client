//
//  AppStoreRatingPlugin.m
//  TriviaSports
//
//  Created by Sergio Kunats on 6/28/12.
//  Copyright (c) 2012 Chugulu. All rights reserved.
//

#import "AppStoreRatingPlugin.h"

NSString* const kCounterKey     = @"AppStoreRatingPluginCount";
NSString* const kDidRateKey     = @"AppStoreRatingPluginDidRate";
NSString* const kNeverAskKey    = @"AppStoreRatingPluginNeverAsk";

#ifndef APP_RATING_COUNTER_MODULO
#define APP_RATING_COUNTER_MODULO 3
#endif

@interface AppStoreRatingPlugin ()

@property (nonatomic, copy) NSString* showCallbackID;

@end

@implementation AppStoreRatingPlugin

@synthesize showCallbackID;


+ (NSURL*) viewContentsUserReviews:(NSString*)appId {
    return [NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", appId]];
}

- (BOOL) openAppStoreRatingPage {
    return [[UIApplication sharedApplication] openURL:[[self class] viewContentsUserReviews:iTunesAppID]];
}

- (NSString *) appVersion {
    NSDictionary* bundleInfo = [[NSBundle mainBundle] infoDictionary];
    return [NSString stringWithFormat:@"%@(%@)",
                                    [bundleInfo objectForKey:@"CFBundleShortVersionString"],
                                    [bundleInfo objectForKey:@"CFBundleVersion"]];
}

- (void) openRatingsPage:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    NSString* callbackID = [arguments objectAtIndex:0];
    BOOL success = [self openAppStoreRatingPage];
    if (success)
        [self sendSuccessResult:[self appVersion] toCallback:callbackID];
    else
        [self sendErrorCode:AppStoreRatingErrorCouldNotOpenRating toCallback:callbackID];
}

- (void) show:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    self.showCallbackID = [arguments objectAtIndex:0];

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[options objectForKey:@"title"]
                                                        message:[options objectForKey:@"message"]
                                                       delegate:self
                                              cancelButtonTitle:[options objectForKey:@"button_cancel"]
                                              otherButtonTitles:[options objectForKey:@"button_rate"], [options objectForKey:@"button_never_ask"], nil];
    [alertView show];
}

- (void) checkShouldRate:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    NSString* callbackID             = [arguments objectAtIndex:0];
    static int previousCount         = 0;
	NSUserDefaults *defaults		 = [NSUserDefaults standardUserDefaults];

	NSInteger numberOfGamesPlayed	 = [defaults integerForKey:kCounterKey];
	BOOL	  hasUserAlreadyRatedApp = [defaults boolForKey:kDidRateKey];
    BOOL      userAskedToNeverAsk    = [defaults boolForKey:kNeverAskKey];

	if (!hasUserAlreadyRatedApp && numberOfGamesPlayed && !userAskedToNeverAsk &&
        (numberOfGamesPlayed % APP_RATING_COUNTER_MODULO) == 0 &&
        previousCount != numberOfGamesPlayed) {
        previousCount = numberOfGamesPlayed;
        [self sendSuccessResult:nil toCallback:callbackID];
	}
    else
        [self sendErrorCode:AppStoreRatingErrorShouldNotRate toCallback:callbackID];
}

- (void) incrementCounter:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    NSString* callbackID             = [arguments objectAtIndex:0];
	NSUserDefaults *defaults		 = [NSUserDefaults standardUserDefaults];
	NSInteger numberOfGamesPlayed	 = [defaults integerForKey:kCounterKey];
    [defaults setInteger:(numberOfGamesPlayed + 1) forKey:kCounterKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self sendSuccessResult:nil toCallback:callbackID];
}

#pragma mark - <UIAlertViewDelegate>

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex { 
    switch (buttonIndex) {
        case AppRatingButtonRate:
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDidRateKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self sendSuccessResult:nil toCallback:self.showCallbackID];
            [self openAppStoreRatingPage];
            break;
        case AppRatingButtonNeverAsk:
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kNeverAskKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self sendErrorCode:AppStoreRatingErrorNeverAsk toCallback:self.showCallbackID];
            break;
        case AppRatingButtonCancel:
            [self sendErrorCode:AppStoreRatingErrorCancelled toCallback:self.showCallbackID];
        default:
            [self sendErrorCode:AppStoreRatingErrorUnknown toCallback:self.showCallbackID];
            break;
    }
}

@end

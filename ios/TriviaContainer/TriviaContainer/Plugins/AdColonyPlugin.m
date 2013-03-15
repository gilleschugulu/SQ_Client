//
//  AdColonyPlugin.m
//  TriviaStars
//
//  Created by Sergio Kunats on 12/17/12.
//  Copyright (c) 2012 Chugulu. All rights reserved.
//

#import "AdColonyPlugin.h"

@interface AdColonyPlugin ()

@property (nonatomic, strong) NSMutableDictionary* zones;
@property (nonatomic, strong) NSMutableDictionary* zoneErrors;
@property (nonatomic, strong) NSMutableDictionary* zoneRewards;
@property (nonatomic, strong) NSString* customData;
@property (nonatomic, strong) NSString* playVideoCallbackID;

@end

@implementation AdColonyPlugin

- (BOOL) zoneExists:(NSString*)zone {
    if (zone != nil)
        for (NSString* existingZone in [self.zones allValues])
            if ([existingZone isEqualToString:zone])
                return YES;
    return NO;
}

- (void) init:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    self.zoneErrors     = [NSMutableDictionary new];
    self.zoneRewards    = [NSMutableDictionary new];
    NSArray* zones      = [options objectForKey:@"zones"];
    if (zones && [zones count] > 0) {
        self.zones = [NSMutableDictionary new];
        int c = 1;
        for (NSString* zone in zones)
            [self.zones setObject:zone forKey:@(c++)];
    }
    [AdColony initAdColonyWithDelegate:self];
}

- (void) playVideo:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    self.playVideoCallbackID= [arguments objectAtIndex:0];
    NSString* zone          = [options objectForKey:@"zone"];

    if (![self zoneExists:zone])
        return [self sendErrorCode:AdColonyPluginErrorUnknownZone toCallback:self.playVideoCallbackID];

    NSNumber* errorCode = [self.zoneErrors objectForKey:zone];
    if (errorCode)
        return [self sendErrorCode:[errorCode intValue] toCallback:self.playVideoCallbackID];

    NSLog(@"virtualCurrencyAwardAvailableForZone %d", [AdColony virtualCurrencyAwardAvailableForZone:zone]);
    NSLog(@"virtualCurrencyAwardsAvailableTodayInZone %d", [AdColony virtualCurrencyAwardsAvailableTodayInZone:zone]);
    NSLog(@"zoneStatusForZone %d", [AdColony zoneStatusForZone:zone]);

    if ([AdColony zoneStatusForZone:zone] != ADCOLONY_ZONE_STATUS_ACTIVE)
        return [self sendErrorCode:AdColonyPluginErrorZoneUnavailable toCallback:self.playVideoCallbackID];

    if (![AdColony virtualCurrencyAwardAvailableForZone:zone] || [AdColony virtualCurrencyAwardsAvailableTodayInZone:zone] < 1)
        return [self sendErrorCode:AdColonyPluginErrorRewardUnavailable toCallback:self.playVideoCallbackID];

    NSNumber* prepropup     = [options objectForKey:@"prepopup"];
    NSNumber* postpropup    = [options objectForKey:@"postpopup"];
//    self.customData         = [options objectForKey:@"custom"];
    [AdColony setCustomID:[options objectForKey:@"custom"]];

    [self.zoneRewards removeObjectForKey:zone];

    [AdColony playVideoAdForZone:zone
                    withDelegate:self
                withV4VCPrePopup:(prepropup ? [prepropup boolValue] : NO)
                andV4VCPostPopup:(postpropup ? [postpropup boolValue] : NO)];
}

#pragma mark - <AdColonyDelegate>

- (NSDictionary *) adColonyAdZoneNumberAssociation {
    return self.zones;
}

- (NSString *) adColonyApplicationID {
    return AdColonyAppID;
}

//- (NSString *) adColonySupplementalVCParametersForZone:(NSString *)zone {
//    return self.customData;
//}

- (NSString *) adColonyLoggingStatus {
    return AdColonyLoggingOn;
}

//Is called when the video zone is turned off or server fails to return videos
-(void)adColonyNoVideoFillInZone:(NSString *)zone {
    [self.zoneErrors setObject:@(AdColonyPluginErrorNoVideoFill) forKey:zone];
}

//Is called when the video zone is ready to serve ads
-(void)adColonyVideoAdsReadyInZone:(NSString *)zone {
    [self.zoneErrors removeObjectForKey:zone];
}

//is called when, temporarily or permanently, video ads have become
//unavailable for any reason
//requesting ads after this method returns and before a subsequent
//adColonyVideoAdsReadyInZone: callback with the same zone will produce no video ads
-(void)adColonyVideoAdsNotReadyInZone:(NSString *)zone {
    [self.zoneErrors setObject:@(AdColonyPluginErrorAdsNotReady) forKey:zone];
}

//Should implement any app-specific code that should be run when AdColony has successfully rewarded
//virtual currency after a video. For example, contact a game server to determine the current total of
//virtual currency after the award.
-(void)adColonyVirtualCurrencyAwardedByZone:(NSString *)zone currencyName:(NSString *)name currencyAmount:(int)amount {
//    [self.zoneRewards setObject:@(amount) forKey:zone];
    [self sendSuccessResult:@(amount) toCallback:self.playVideoCallbackID];
}

//Should implement any app-specific code that should be run when AdColony has failed to reward virtual
//currency after a video. For example, update the user interface with the results of calling
//virtualCurrencyAwardAvailable to disable or enable launching virtual currency videos.
-(void)adColonyVirtualCurrencyNotAwardedByZone:(NSString *)zone currencyName:(NSString *)name currencyAmount:(int)amount reason:(NSString *)reason {
//    [self.zoneRewards removeObjectForKey:zone];
    [self sendErrorCode:AdColonyPluginErrorCoundNotReward toCallback:self.playVideoCallbackID];
}

#pragma mark - <AdColonyTakeoverAdDelegate>

//Should implement any app-specific code that should be run when an ad that takes over the screen begins
//(for example, pausing a game if a video ad is being served in the middle of a session).
-(void)adColonyTakeoverBeganForZone:(NSString *)zone {

}

//Should implement any app-specific code that should be run when an ad that takes over the screen ends
//(for example, resuming a game if a video ad was served in the middle of a session).
-(void)adColonyTakeoverEndedForZone:(NSString *)zone withVC:(BOOL)withVirtualCurrencyAward {
//    NSNumber* reward = (withVirtualCurrencyAward ? [self.zoneRewards objectForKey:zone] : @(0));
//    if (reward)
//        [self sendSuccessResult:reward toCallback:self.playVideoCallbackID];
//    else
//        [self sendErrorCode:AdColonyPluginErrorCoundNotReward toCallback:self.playVideoCallbackID];
//    [self.zoneRewards removeObjectForKey:zone];
}

//Should implement any app-specific code that should be run when AdColony is unable to play a video ad
//or virtual currency video ad
-(void)adColonyVideoAdNotServedForZone:(NSString *)zone {
    [self sendErrorCode:AdColonyPluginErrorCouldNotLoad toCallback:self.playVideoCallbackID];
}

@end

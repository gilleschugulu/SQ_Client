//
//  AdColonyPlugin.h
//  TriviaStars
//
//  Created by Sergio Kunats on 12/17/12.
//  Copyright (c) 2012 Chugulu. All rights reserved.
//

#import "BasePlugin.h"
#import <AdColonyPublic.h>

typedef enum {
    AdColonyPluginErrorUnknown          = 0,
    AdColonyPluginErrorCoundNotReward   = 1,
    AdColonyPluginErrorCouldNotLoad     = 2,
    AdColonyPluginErrorAdsNotReady      = 3,
    AdColonyPluginErrorNoVideoFill      = 4,
    AdColonyPluginErrorUnknownZone      = 5,
    AdColonyPluginErrorZoneUnavailable  = 6,
    AdColonyPluginErrorRewardUnavailable= 7
} AdColonyPluginErrorCode;

@interface AdColonyPlugin : BasePlugin <AdColonyDelegate, AdColonyTakeoverAdDelegate>

@end

//
//  ChartBoostPlugin.h
//  TriviaSports
//
//  Created by Sergio Kunats on 6/27/12.
//  Copyright (c) 2012 Chugulu. All rights reserved.
//

#import "BasePlugin.h"
#import "Chartboost.h"

typedef enum {
    ChartBoostErrorUnknown                  = 0,
    ChartBoostErrorFailedToLoadInterstitial = 1
} ChartBoostError;

@interface ChartBoostPlugin : BasePlugin <ChartboostDelegate>

@end

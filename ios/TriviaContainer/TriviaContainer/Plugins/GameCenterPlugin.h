//
//  GameCenter.h
//  TriviaSports
//
//  Created by Sergio Kunats on 6/11/12.
//  Copyright (c) 2012 Chugulu. All rights reserved.
//

#import <GameKit/GameKit.h>
#import "BasePlugin.h"
#import "GameCenterManager.h"

typedef enum {
    GameCenterErrorUnknown                  = 0,
    GameCenterErrorCouldNotAuthenticate     = 1,
    GameCenterErrorCouldNotReportScore      = 2,
    GameCenterErrorMissingLeaderboardID     = 3,
    GameCenterErrorMissingScore             = 4,
    GameCenterErrorNotAvailable             = 5,
    GameCenterErrorNotAuthenticated         = 6,
    GameCenterErrorCouldNotRetrieveFriends  = 7
} GameCenterError;

@interface GameCenterPlugin : BasePlugin <GameCenterManagerDelegate, GKLeaderboardViewControllerDelegate>

@end

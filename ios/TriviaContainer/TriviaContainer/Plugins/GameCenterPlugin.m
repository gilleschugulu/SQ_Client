//
//  GameCenter.m
//  TriviaSports
//
//  Created by Sergio Kunats on 6/11/12.
//  Copyright (c) 2012 Chugulu. All rights reserved.
//

#import "GameCenterPlugin.h"

@interface GameCenterPlugin ()

@property (nonatomic, strong) GameCenterManager* gcManager;
@property (nonatomic, copy) NSString* authenticatePlayerCallbackID;
@property (nonatomic, copy) NSString* reportScoreCallbackID;
@property (nonatomic, copy) NSString* showLeaderboardCallbackID;
@property (nonatomic, assign) BOOL userAuthenticated;

@end

@implementation GameCenterPlugin

@synthesize gcManager;
@synthesize authenticatePlayerCallbackID;
@synthesize reportScoreCallbackID;
@synthesize showLeaderboardCallbackID;
@synthesize userAuthenticated;


- (CDVPlugin*) initWithWebView:(UIWebView *)theWebView {
    if ((self = [super initWithWebView:theWebView])) {
        GameCenterManager* gc = [[GameCenterManager alloc] init];
        self.gcManager = gc;
        self.gcManager.delegate = self;
        self.authenticatePlayerCallbackID = nil;
        self.showLeaderboardCallbackID = nil;
        self.reportScoreCallbackID = nil;
        self.userAuthenticated = NO;
    }
    return self;
}

- (void) reportScore:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    self.reportScoreCallbackID  = [arguments objectAtIndex:0];
    if (![GameCenterManager isGameCenterAvailable])
        return [self sendErrorCode:GameCenterErrorNotAvailable toCallback:self.reportScoreCallbackID];
    if (!self.userAuthenticated)
        return [self sendErrorCode:GameCenterErrorNotAuthenticated toCallback:self.reportScoreCallbackID];
    NSString* leaderboard       = [options objectForKey:@"leaderboard"];
    NSNumber* points            = [options objectForKey:@"points"];
    if (leaderboard == nil) 
        return [self sendErrorCode:GameCenterErrorMissingLeaderboardID toCallback:self.reportScoreCallbackID];
    if (points == nil)
        return [self sendErrorCode:GameCenterErrorMissingScore toCallback:self.reportScoreCallbackID];
    [self.gcManager reportScore:(int64_t)[points integerValue] forCategory:leaderboard];
}

- (void) authenticateLocalUser:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    self.authenticatePlayerCallbackID = [arguments objectAtIndex:0];
    if (![GameCenterManager isGameCenterAvailable])
        return [self sendErrorCode:GameCenterErrorNotAvailable toCallback:self.authenticatePlayerCallbackID];
    [self.gcManager authenticateLocalUser];
}

- (void) showLeaderboard:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    self.showLeaderboardCallbackID = [arguments objectAtIndex:0];
    if (![GameCenterManager isGameCenterAvailable])
        return [self sendErrorCode:GameCenterErrorNotAvailable toCallback:self.showLeaderboardCallbackID];
    NSString* leaderboard          = nil;
    if ([arguments count] > 1)
        leaderboard = [arguments objectAtIndex:1];
    GKLeaderboardViewController* gkVC = [GKLeaderboardViewController new];
    if (leaderboard != nil && ![leaderboard isEqualToString:@""])
        gkVC.category = leaderboard;
    gkVC.leaderboardDelegate = self;
    [self.viewController presentViewController:gkVC animated:YES completion:nil];
}

- (void) requestFriendList:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    __block NSString* callbackID = [arguments objectAtIndex:0];
    if (![GameCenterManager isGameCenterAvailable])
        return [self sendErrorCode:GameCenterErrorNotAvailable toCallback:callbackID];
    if (!self.userAuthenticated || [GKLocalPlayer localPlayer] == nil)
        return [self sendErrorCode:GameCenterErrorNotAuthenticated toCallback:self.reportScoreCallbackID];

    [[GKLocalPlayer localPlayer] loadFriendsWithCompletionHandler:^(NSArray* friends, NSError* error) {
        if (error)
            [self sendErrorCode:GameCenterErrorCouldNotRetrieveFriends toCallback:callbackID];
        else
            [GKPlayer loadPlayersForIdentifiers:friends withCompletionHandler:^(NSArray* players, NSError* playerError) {
                if (playerError)
                    [self sendErrorCode:GameCenterErrorCouldNotRetrieveFriends toCallback:callbackID];
                else {
                    NSMutableArray* playerNames = [[NSMutableArray alloc] initWithCapacity:[players count]];
                    for (GKPlayer* player in players)
                        [playerNames addObject:player.alias];
                    [self sendSuccessResult:playerNames toCallback:callbackID];
                }
            }];
    }];
}

#pragma mark - <GKLeaderboardViewControllerDelegate>

- (void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController {
    [self.viewController dismissViewControllerAnimated:YES completion:^{
        [self sendSuccessResult:nil toCallback:self.showLeaderboardCallbackID]; 
    }];
}

#pragma mark - <GameCenterManagerDelegate>

- (void) processGameCenterAuth:(UIViewController*)viewController error:(NSError*)error {
    if (self.authenticatePlayerCallbackID == nil)
        return;
    if (error)
        [self sendErrorCode:GameCenterErrorCouldNotAuthenticate toCallback:self.authenticatePlayerCallbackID];

    if (viewController) {
//        if (([self.viewController respondsToSelector:@selector(supportedInterfaceOrientations)] &&
//            self.viewController.supportedInterfaceOrientations & UIInterfaceOrientationMaskPortrait) ||
//            UIInterfaceOrientationIsPortrait(self.viewController.interfaceOrientation))
//            [self.viewController presentViewController:viewController animated:YES completion:nil];
    } else {
        self.userAuthenticated = YES;
        [self sendSuccessResult:[GKLocalPlayer localPlayer].alias toCallback:self.authenticatePlayerCallbackID];
    }
}

- (void) processGameCenterAuth:(NSError*)error {
    [self processGameCenterAuth:nil error:error];
}

- (void) scoreReported:(NSError*)error {
    if (self.reportScoreCallbackID == nil)
        return;
    if (error)
        [self sendErrorCode:GameCenterErrorCouldNotReportScore toCallback:self.reportScoreCallbackID];
    else
        [self sendSuccessResult:nil toCallback:self.reportScoreCallbackID];
}


- (void) reloadScoresComplete:(GKLeaderboard*)leaderBoard error:(NSError*)error {
    
}

- (void) achievementSubmitted:(GKAchievement*)ach error:(NSError*)error {
    
}

- (void) achievementResetResult:(NSError*)error {
    
}

- (void) mappedPlayerIDToPlayer:(GKPlayer*)player error:(NSError*)error {
    
}

@end

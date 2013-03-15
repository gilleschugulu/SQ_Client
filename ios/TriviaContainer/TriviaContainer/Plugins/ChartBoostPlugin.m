//
//  ChartBoostPlugin.m
//  TriviaSports
//
//  Created by Sergio Kunats on 6/27/12.
//  Copyright (c) 2012 Chugulu. All rights reserved.
//

#import "ChartBoostPlugin.h"

@interface ChartBoostPlugin ()

@property (nonatomic, copy) NSString* callbackID;

@end

@implementation ChartBoostPlugin

@synthesize callbackID;

- (CDVPlugin*) initWithWebView:(UIWebView *)theWebView {
    Chartboost *cb  = [Chartboost sharedChartboost];
    cb.appId        = ChartBoostAppID;
    cb.appSignature = ChartBoostAppSignature;
    [cb startSession];
    return (self = [super initWithWebView:theWebView]);
}


- (void) cacheInterstitial:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    self.callbackID = [arguments objectAtIndex:0];
    Chartboost *cb  = [Chartboost sharedChartboost];
    if (![cb hasCachedInterstitial])
        [cb cacheInterstitial];
    [self sendSuccessResult:nil toCallback:self.callbackID];
}

- (void) showInterstitial:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    self.callbackID = [arguments objectAtIndex:0];
    Chartboost *cb  = [Chartboost sharedChartboost];
    if ([cb hasCachedInterstitial]) {
        cb.delegate = self;
        [cb showInterstitial];
    } else
        [self didFailToLoadInterstitial];
}

#pragma mark - <ChartBoostDelegate>

// Called when an interstitial has failed to come back from the server
- (void)didFailToLoadInterstitial {
    [self sendErrorCode:ChartBoostErrorFailedToLoadInterstitial toCallback:self.callbackID];
}

// Called when the user dismisses the interstitial
// If you are displaying the add yourself, dismiss it now.
- (void)didDismissInterstitial:(NSString *)location {
    [self sendSuccessResult:nil toCallback:self.callbackID];
}

// Same as above, but only called when dismissed for a close
- (void)didCloseInterstitial:(NSString *)location {
    [self sendSuccessResult:nil toCallback:self.callbackID];
}

@end

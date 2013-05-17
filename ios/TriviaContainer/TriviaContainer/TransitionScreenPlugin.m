//
//  TransitionScreenPlugin.m
//  TriviaContainer
//
//  Created by Sergio Kunats on 3/13/13.
//  Copyright (c) 2013 Chugulu. All rights reserved.
//

#import "TransitionScreenPlugin.h"

@interface TransitionScreenPlugin ()
@property(nonatomic, strong) UIView* transitionView;
@end

@implementation TransitionScreenPlugin
@synthesize transitionView;

-(void)unDim:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    NSString* callback = arguments[0];
    if (self.transitionView == nil){
        return [self sendErrorCode:0 toCallback:callback];
    }
    NSTimeInterval duration = options[@"duration"] ? [(NSNumber*)options[@"duration"] doubleValue] : 0.35;
    [UIView animateWithDuration:duration
                     animations:^{self.transitionView.alpha = 0.0f;}
                     completion:^(BOOL finished)
    {
         if (finished) {
             [self sendSuccessResult:nil toCallback:callback];
             [self.transitionView removeFromSuperview];
             self.transitionView = nil;
         }
    }];
}

-(void)dim:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    NSString* callback = arguments[0];
    NSTimeInterval duration = options[@"duration"] ? [(NSNumber*)options[@"duration"] doubleValue] : 0.35;
    self.transitionView = [[UIView alloc] initWithFrame:self.webView.frame];
    self.transitionView.backgroundColor = [UIColor blackColor];
    self.transitionView.alpha = 0.0f;
    [self.webView addSubview:self.transitionView];
    [UIView animateWithDuration:duration
                     animations:^{self.transitionView.alpha = 1.0f;}
                     completion:^(BOOL finished)
     {
         if (finished) {
             [self sendSuccessResult:nil toCallback:callback];
         }
     }];
}

@end

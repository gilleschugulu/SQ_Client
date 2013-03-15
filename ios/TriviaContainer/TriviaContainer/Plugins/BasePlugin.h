//
//  BasePlugin.h
//  TriviaSports
//
//  Created by Sergio Kunats on 6/11/12.
//  Copyright (c) 2012 Chugulu. All rights reserved.
//

#import "CDVPlugin.h"

@interface BasePlugin : CDVPlugin

- (void) sendErrorCode:(int)code toCallback:(NSString *)callbackID;
- (void) sendSuccessResult:(id)result toCallback:(NSString *)callbackID;

@end

//
//  BasePlugin.m
//  TriviaSports
//
//  Created by Sergio Kunats on 6/11/12.
//  Copyright (c) 2012 Chugulu. All rights reserved.
//

#import "BasePlugin.h"

@implementation BasePlugin

#pragma mark - Response to Javascript

- (void) sendErrorCode:(int)code toCallback:(NSString *)callbackID {
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR 
                                                 messageToErrorObject:code];
    [self error:pluginResult callbackId:callbackID];
}

- (void) sendSuccessResult:(id)result toCallback:(NSString *)callbackID {
    CDVPluginResult* pluginResult = nil;
    if ([result isKindOfClass:[NSArray class]])
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                          messageAsArray:result];
    else if ([result isKindOfClass:[NSDictionary class]])
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                     messageAsDictionary:result];
    else if ([result isKindOfClass:[NSString class]])
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                         messageAsString:result];
    else if ([result isKindOfClass:[NSNumber class]])
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                            messageAsInt:[result intValue]];
    if (pluginResult == nil)
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self success:pluginResult callbackId:callbackID];
}

@end

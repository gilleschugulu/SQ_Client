//
//  FacebookConnectPlugin.h
//  GapFacebookConnect
//
//  Created by Jesse MacFadyen on 11-04-22.
//  Copyright 2011 Nitobi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Facebook.h"
#import "BasePlugin.h"

#ifdef CORDOVA_FRAMEWORK
    #import <Cordova/CDVPlugin.h>
    #import <Cordova/CDVPluginResult.h>
#else
    #import "CDVPlugin.h"
    #import "CDVPluginResult.h"
#endif


@interface FacebookConnectPlugin : BasePlugin

@end

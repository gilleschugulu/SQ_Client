NSString * const NSURLIsExcludedFromBackupKey = @"NSURLIsExcludedFromBackupKey";
/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

//
//  AppDelegate.m
//  TriviaSports
//
//  Created by Sergio Kunats on 5/14/12.
//  Copyright Chugulu 2012. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"


#import "CDVPlugin.h"
#import "CDVURLProtocol.h"

#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "TestFlight.h"
#import "PushNotificationsPlugin.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (void) emptyCacheOnVersionChange {
    NSDictionary* bundleInfo = [[NSBundle mainBundle] infoDictionary];
    NSString* currentVersion = [[NSString alloc] initWithFormat:@"%@(%@)",
                                [bundleInfo objectForKey:@"CFBundleShortVersionString"], 
                                [bundleInfo objectForKey:@"CFBundleVersion"]];
    NSString* cacheVersion = [[NSUserDefaults standardUserDefaults] stringForKey:@"CacheVersion"];
    if (![currentVersion isEqualToString:cacheVersion]) {
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:@"CacheVersion"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (id)init
{
    NSError* err = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:&err]; // don't stop iPod music at launch
    if (err == nil)
        [[AVAudioSession sharedInstance] setActive:YES error:NULL];

#ifdef TESTFLIGHT_UDID
    UIDevice* device = [UIDevice currentDevice];
    if ([device respondsToSelector:@selector(uniqueIdentifier)])
        [TestFlight setDeviceIdentifier:[device performSelector:@selector(uniqueIdentifier)]];
#endif
    [TestFlight takeOff:TestFlightTeamToken];

    NSHTTPCookieStorage* cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];

    [cookieStorage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];

    if ((self = [super init]))
        [self emptyCacheOnVersionChange];
    return self;
}

- (void)createViewController
{
    NSAssert(!self.viewController, @"ViewController already created.");

    self.viewController = [ViewController new];
    self.viewController.useSplashScreen = NO;

    // NOTE: To control the view's frame size, override [self.viewController viewWillAppear:] in your view controller.

    self.window.rootViewController = self.viewController;
}

- (void)destroyViewController
{
    // Clean up circular refs so that the view controller will actully be released.
//    [self.viewController dispose];
    self.viewController = nil;
    self.window.rootViewController = nil;
}

#pragma UIApplicationDelegate implementation

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    application.idleTimerDisabled = YES;

    CGRect screenBounds = [[UIScreen mainScreen] bounds];

    self.window = [[UIWindow alloc] initWithFrame:screenBounds];
    self.window.autoresizesSubviews = YES;

    // Create the main view on start-up only when not running unit tests.
    if (!NSClassFromString(@"CDVWebViewTest")) {
        [self createViewController];
    }

    [self.window makeKeyAndVisible];

    return YES;
}

// this happens while we are running ( in the background, or from within our own app )
// only valid if TriviaSports-Info.plist specifies a protocol to handle
- (BOOL) application:(UIApplication*)application handleOpenURL:(NSURL*)url
{
    if (!url)
        return NO;

	// calls into javascript global function 'handleOpenURL'
    NSString* jsString = [NSString stringWithFormat:@"handleOpenURL(\"%@\");", url];
    [self.viewController.webView stringByEvaluatingJavaScriptFromString:jsString];

    // all plugins will get the notification, and their handlers will be called
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:CDVPluginHandleOpenURLNotification object:url]];
    return YES;
}

// repost the localnotification using the default NSNotificationCenter so multiple plugins may respond
- (void)           application:(UIApplication*)application
   didReceiveLocalNotification:(UILocalNotification*)notification
{
    // re-post ( broadcast )
    [[NSNotificationCenter defaultCenter] postNotificationName:CDVLocalNotification object:notification];
}

- (void) applicationWillEnterForeground:(UIApplication *)application {
    application.applicationIconBadgeNumber = 0;
}

#pragma mark Apple Push Notification System

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:deviceToken forKey:PushNotificationsPluginTokenKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:PushNotificationsPluginDidRegisterNotification object:nil userInfo:userInfo];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:error forKey:PushNotificationsPluginErrorKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:PushNotificationsPluginRegistrationFailedNotification object:nil userInfo:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [[NSNotificationCenter defaultCenter] postNotificationName:PushNotificationsPluginDidReceiveNotification object:nil userInfo:userInfo];
}

@end

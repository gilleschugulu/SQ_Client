//
//  PushNotificationsPlugin.m
//  TriviaSports
//
//  Created by Sergio Kunats on 6/28/12.
//  Copyright (c) 2012 Chugulu. All rights reserved.
//

#import "PushNotificationsPlugin.h"

NSString* const PushNotificationsPluginDidRegisterNotification          = @"PushNotificationsPluginDidRegisterNotification";
NSString* const PushNotificationsPluginRegistrationFailedNotification   = @"PushNotificationsPluginRegistrationFailedNotification";
NSString* const PushNotificationsPluginDidReceiveNotification           = @"PushNotificationsPluginDidReceiveNotification";
NSString* const PushNotificationsPluginTokenKey                         = @"token";
NSString* const PushNotificationsPluginApsEnvKey                        = @"aps_environment";
NSString* const PushNotificationsPluginErrorKey                         = @"error";
NSString* const PushNotificationsPluginUrlKey                           = @"PushNotificationPluginUrl";
NSString* const kDidRegisterKey                                         = @"PushNotificationPluginDidRegister";

/* options for -configure method */
NSString* const kOptionsButtonCancelKey = @"buttonCancel";
NSString* const kOptionsButtonOKKey     = @"buttonOK";

@interface PushNotificationsPlugin ()

@property (nonatomic, copy) NSString* registerCallbackID;
@property (nonatomic, assign) BOOL blocked;
@property (nonatomic, strong) NSMutableArray* notificationQueue;
@property (nonatomic, copy) NSString* alertButtonCancelTitle;
@property (nonatomic, copy) NSString* alertButtonOKTitle;

@end

@implementation PushNotificationsPlugin

@synthesize registerCallbackID;
@synthesize blocked;
@synthesize notificationQueue;
@synthesize alertButtonCancelTitle;
@synthesize alertButtonOKTitle;

- (CDVPlugin*) initWithWebView:(UIWebView *)theWebView {
    if ((self = [super initWithWebView:theWebView])) {
        self.blocked = NO;
        self.registerCallbackID = nil;
        NSMutableArray* nq = [NSMutableArray new];
        self.notificationQueue = nq;
        self.alertButtonCancelTitle = @"No, thank you";
        self.alertButtonOKTitle = @"OK";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceive:) name:PushNotificationsPluginDidReceiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetBadge) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PushNotificationsPluginDidRegisterNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PushNotificationsPluginRegistrationFailedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PushNotificationsPluginDidReceiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void) resetBadge {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void) displayNotification:(NSDictionary *)userInfo {
    NSDictionary* aps = [userInfo objectForKey:@"aps"];
    [self resetBadge];
    
    if ([userInfo objectForKey:@"url"]) {
        [[NSUserDefaults standardUserDefaults] setURL:[NSURL URLWithString:[userInfo objectForKey:@"url"]] forKey:PushNotificationsPluginUrlKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]
                                                        message:[aps objectForKey:@"alert"]
                                                       delegate:([userInfo objectForKey:@"url"] ? self : nil)
                                              cancelButtonTitle:([userInfo objectForKey:@"url"] ? self.alertButtonCancelTitle : nil)
                                              otherButtonTitles:self.alertButtonOKTitle, nil];
    [alertView show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != 1)
        return;
    NSURL* url = [[NSUserDefaults standardUserDefaults] URLForKey:PushNotificationsPluginUrlKey];
    if (!url)
        return;
    [[NSUserDefaults standardUserDefaults] setURL:nil forKey:PushNotificationsPluginUrlKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[UIApplication sharedApplication] openURL:url];
}

- (void) didReceive:(NSNotification *)notification {
    NSDictionary* aps = [notification.userInfo objectForKey:@"aps"];
    [UIApplication sharedApplication].applicationIconBadgeNumber += [[aps objectForKey:@"badge"] integerValue];
    if (self.blocked)
        [self.notificationQueue addObject:notification.userInfo];
    else
        [self displayNotification:notification.userInfo];
}

- (void) didRegister:(NSNotification *)notification {
    if (self.registerCallbackID) {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:kDidRegisterKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
// Formating device token
//
// for example:
//		<b5213050 fbada87f 3e838c9d 00226567 8f06416e cf812939 278f7148 37a91b0a>
// becomes
//		b5213050 fbada87f 3e838c9d 00226567 8f06416e cf812939 278f7148 37a91b0a
        NSData* deviceToken             = [notification.userInfo objectForKey:PushNotificationsPluginTokenKey];
        NSString* formatedDeviceToken   = [[[NSString stringWithFormat:@"%@", deviceToken]
                                                stringByReplacingOccurrencesOfString:@"<" withString:@""]
                                                stringByReplacingOccurrencesOfString:@">" withString:@""];

        NSDictionary* apn = [[NSDictionary alloc] initWithObjectsAndKeys:formatedDeviceToken, PushNotificationsPluginTokenKey,
#ifdef DEBUG
                             @"development"
#else
                             @"production"
#endif
                             , PushNotificationsPluginApsEnvKey, nil];
        [self sendSuccessResult:apn toCallback:self.registerCallbackID];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PushNotificationsPluginDidRegisterNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PushNotificationsPluginRegistrationFailedNotification object:nil];
}

- (void) registrationFailed:(NSNotification *)notification {
    if (self.registerCallbackID) {
//        NSError* error = [notification.userInfo objectForKey:PushNotificationsPluginErrorKey];
        [self sendErrorCode:0 toCallback:self.registerCallbackID];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PushNotificationsPluginDidRegisterNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PushNotificationsPluginRegistrationFailedNotification object:nil];
}

- (void) checkIsRegistered:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    NSString* callbackID = [arguments objectAtIndex:0];
    NSNumber* value = [[NSNumber alloc] initWithInteger:[[NSUserDefaults standardUserDefaults] integerForKey:kDidRegisterKey]];
    [self sendSuccessResult:value toCallback:callbackID];
}

- (void) register:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    self.registerCallbackID = [arguments objectAtIndex:0];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRegister:) name:PushNotificationsPluginDidRegisterNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registrationFailed:) name:PushNotificationsPluginRegistrationFailedNotification object:nil];
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
}

- (void) configure:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    NSString* buttonCancelTitle = [options objectForKey:kOptionsButtonCancelKey];
    NSString* buttonOKTitle     = [options objectForKey:kOptionsButtonOKKey];

    if (buttonCancelTitle)
        self.alertButtonCancelTitle = buttonCancelTitle;
    if (buttonOKTitle)
        self.alertButtonOKTitle = buttonOKTitle;
}

- (void) block:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    if (self.blocked == YES)
        return;
    self.blocked = YES;
}

- (void) unblock:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    if (self.blocked == NO)
        return;
    self.blocked = NO;
    for (NSDictionary* userInfo in self.notificationQueue)
        [self displayNotification:userInfo];
    [self.notificationQueue removeAllObjects];
}

@end

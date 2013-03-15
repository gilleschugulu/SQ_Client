//
//  PushNotificationsPlugin.h
//  TriviaSports
//
//  Created by Sergio Kunats on 6/28/12.
//  Copyright (c) 2012 Chugulu. All rights reserved.
//

#import "BasePlugin.h"

extern NSString* const PushNotificationsPluginDidRegisterNotification;
extern NSString* const PushNotificationsPluginRegistrationFailedNotification;
extern NSString* const PushNotificationsPluginDidReceiveNotification;
extern NSString* const PushNotificationsPluginTokenKey;
extern NSString* const PushNotificationsPluginErrorKey;

@interface PushNotificationsPlugin : BasePlugin <UIAlertViewDelegate>

@end

//
//  SocialPlugin.h
//  TriviaStars
//
//  Created by Sergio Kunats on 9/21/12.
//  Copyright (c) 2012 Chugulu. All rights reserved.
//

#import "BasePlugin.h"
#import <Twitter/Twitter.h>
#import <Social/Social.h>

typedef enum {
    SocialErrorUnknown                  = 0,
    SocialErrorCantMessage              = 1,
    SocialErrorMessageTooLong           = 2,
    SocialErrorUrlTooLong               = 3,
    SocialErrorImageTooLong             = 4,
    SocialErrorMessageCancelled         = 5,
    SocialErrorServiceUnknown           = 6,
    SocialErrorCouldNotCreateComposer   = 7
} SocialError;

@interface SocialPlugin : BasePlugin

@end

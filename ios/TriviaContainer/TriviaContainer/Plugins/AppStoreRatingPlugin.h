//
//  AppStoreRatingPlugin.h
//  TriviaSports
//
//  Created by Sergio Kunats on 6/28/12.
//  Copyright (c) 2012 Chugulu. All rights reserved.
//

#import "BasePlugin.h"

typedef enum {
    AppRatingButtonCancel     = 0,
    AppRatingButtonRate       = 1,
    AppRatingButtonNeverAsk   = 2
} AppRatingButton;

typedef enum {
    AppStoreRatingErrorUnknown            = 0,
    AppStoreRatingErrorNeverAsk           = 1,
    AppStoreRatingErrorCancelled          = 2,
    AppStoreRatingErrorShouldNotRate      = 3,
    AppStoreRatingErrorCouldNotOpenRating = 4
} AppStoreRatingError;

#define isValidRatingButton(buttonIndex) (buttonIndex == AppRatingButtonCancel || buttonIndex == AppRatingButtonRate || buttonIndex == AppRatingButtonNeverAsk)

@interface AppStoreRatingPlugin : BasePlugin <UIAlertViewDelegate>

@end

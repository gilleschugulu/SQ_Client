//
//  SocialPlugin.m
//  TriviaStars
//
//  Created by Sergio Kunats on 9/21/12.
//  Copyright (c) 2012 Chugulu. All rights reserved.
//

#import "SocialPlugin.h"

NSString* const kSocialPluginServiceFacebookKey   = @"facebook";
NSString* const kSocialPluginServiceSinaWeiboKey  = @"sinaweibo";
NSString* const kSocialPluginServiceTwitterKey    = @"twitter";

NSString* const kSocialPluginOptionsServiceNameKey= @"serviceName";
NSString* const kSocialPluginOptionsTextKey       = @"text";
NSString* const kSocialPluginOptionsImageURLKey   = @"imageUrl";
NSString* const kSocialPluginOptionsURLKey        = @"url";

@implementation SocialPlugin

+ (BOOL) isSocialAvailable {
    return [SLComposeViewController class] != nil;
}

+ (NSString *) serviceTypeForName:(NSString *)serviceName {
    if ([serviceName isEqualToString:kSocialPluginServiceFacebookKey])
        return SLServiceTypeFacebook;
    if ([serviceName isEqualToString:kSocialPluginServiceSinaWeiboKey])
        return SLServiceTypeSinaWeibo;
    if ([serviceName isEqualToString:kSocialPluginServiceTwitterKey])
        return SLServiceTypeTwitter;
    return nil;
}

- (void) availableServices:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    NSString* callbackID = [arguments objectAtIndex:0];
    NSMutableDictionary* services = [NSMutableDictionary new];

    if ([[self class] isSocialAvailable]) {
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
            [services setObject:@"1" forKey:kSocialPluginServiceFacebookKey];
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
            [services setObject:@"1" forKey:kSocialPluginServiceTwitterKey];
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeSinaWeibo])
            [services setObject:@"1" forKey:kSocialPluginServiceSinaWeiboKey];
    } else if ([TWTweetComposeViewController canSendTweet])
        [services setObject:@"1" forKey:kSocialPluginServiceTwitterKey];
    [self sendSuccessResult:services toCallback:callbackID];
}

- (UIImage *) createImageFromImageURL:(NSString *)imageURL {
    NSData* imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:imageURL]];
    if (imageData) {
        UIImage* image = [[UIImage alloc] initWithData:imageData];
        return image;
    }
    return nil;
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
- (void) composeTweet:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    NSString* callbackID = [arguments objectAtIndex:0];
    TWTweetComposeViewController* tw = [TWTweetComposeViewController new];
    if (tw == nil)
        return [self sendErrorCode:SocialErrorCouldNotCreateComposer toCallback:callbackID];
    NSString* text      = [options objectForKey:kSocialPluginOptionsTextKey];
    NSString* url       = [options objectForKey:kSocialPluginOptionsURLKey];
    NSString* imageUrl  = [options objectForKey:kSocialPluginOptionsImageURLKey];

    if (text != nil && ![tw setInitialText:text])
        return [self sendErrorCode:SocialErrorMessageTooLong toCallback:callbackID];
    if (url != nil && ![tw addURL:[NSURL URLWithString:url]])
        return [self sendErrorCode:SocialErrorMessageTooLong toCallback:callbackID];

    if (imageUrl != nil) {
        UIImage* image = [self createImageFromImageURL:imageUrl];
        if (image) {
            BOOL result = [tw addImage:image];
            if (!result)
                return [self sendErrorCode:SocialErrorImageTooLong toCallback:callbackID];
        }
    }
    [tw setCompletionHandler:^(TWTweetComposeViewControllerResult tweetResult) {
        [self.viewController dismissViewControllerAnimated:YES completion:nil];
        if (tweetResult == TWTweetComposeViewControllerResultDone)
            [self sendSuccessResult:nil toCallback:callbackID];
        else if (tweetResult == TWTweetComposeViewControllerResultCancelled)
            [self sendErrorCode:SocialErrorMessageCancelled toCallback:callbackID];
        else
            [self sendErrorCode:SocialErrorUnknown toCallback:callbackID];
    }];
    [self.viewController presentViewController:tw animated:YES completion:nil];
}
#endif

- (void) composeMessage:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    NSString* serviceName= [options objectForKey:kSocialPluginOptionsServiceNameKey];

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
    if (![[self class] isSocialAvailable]) // FALLBACK
        if ([serviceName isEqualToString:kSocialPluginServiceTwitterKey])
            return [self composeTweet:arguments withDict:options]; // Twitter fallback pre iOS6
#else
#error You dont need composeTweet: fallback on iOS6+ target, you can remove it
#endif
    NSString* callbackID = [arguments objectAtIndex:0];
    NSString* serviceType= [[self class] serviceTypeForName:serviceName];
    if (!serviceType)
        return [self sendErrorCode:SocialErrorServiceUnknown toCallback:callbackID];
    SLComposeViewController* composer = [SLComposeViewController composeViewControllerForServiceType:serviceType];
    if (composer == nil)
        return [self sendErrorCode:SocialErrorCouldNotCreateComposer toCallback:callbackID];
    NSString* text      = [options objectForKey:kSocialPluginOptionsTextKey];
    NSString* url       = [options objectForKey:kSocialPluginOptionsURLKey];
    NSString* imageUrl  = [options objectForKey:kSocialPluginOptionsImageURLKey];

    if (text != nil && ![composer setInitialText:text])
        return [self sendErrorCode:SocialErrorMessageTooLong toCallback:callbackID];
    if (url != nil && ![composer addURL:[NSURL URLWithString:url]])
        return [self sendErrorCode:SocialErrorMessageTooLong toCallback:callbackID];

    if (imageUrl != nil) {
        UIImage* image = [self createImageFromImageURL:imageUrl];
        if (image) {
            BOOL result = [composer addImage:image];
            if (!result)
                return [self sendErrorCode:SocialErrorImageTooLong toCallback:callbackID];
        }
    }
    [composer setCompletionHandler:^(SLComposeViewControllerResult messageResult) {
        [self.viewController dismissViewControllerAnimated:YES completion:nil];
        if (messageResult == SLComposeViewControllerResultDone)
            [self sendSuccessResult:nil toCallback:callbackID];
        else if (messageResult == SLComposeViewControllerResultCancelled)
            [self sendErrorCode:SocialErrorMessageCancelled toCallback:callbackID];
        else
            [self sendErrorCode:SocialErrorUnknown toCallback:callbackID];
    }];
    [self.viewController presentViewController:composer animated:YES completion:nil];
}


@end

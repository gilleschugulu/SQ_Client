//
//  Message.m
//  TriviaSports
//
//  Created by Sergio Kunats on 6/12/12.
//  Copyright (c) 2012 Chugulu. All rights reserved.
//

#import "MessagePlugin.h"

@interface MessagePlugin ()

@property (nonatomic, copy) NSString* composeMessageCallbackID;
@property (nonatomic, copy) NSString* composeMailCallbackID;

@end

@implementation MessagePlugin

@synthesize composeMessageCallbackID;
@synthesize composeMailCallbackID;


- (void) composeMessage:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    self.composeMessageCallbackID = [arguments objectAtIndex:0];
    if (![MFMessageComposeViewController canSendText])
        return [self sendErrorCode:MessageErrorCantSendText toCallback:self.composeMessageCallbackID];
    NSString* messageBody       = [options objectForKey:@"body"];
    NSArray* messageRecipients  = [options objectForKey:@"recipients"];
    MFMessageComposeViewController* mc = [MFMessageComposeViewController new];
    mc.messageComposeDelegate   = self;
    mc.body                     = messageBody;
    mc.recipients               = messageRecipients;
    [self.viewController presentViewController:mc animated:YES completion:nil];
}

- (void) composeMail:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    self.composeMailCallbackID = [arguments objectAtIndex:0];
    if (![MFMailComposeViewController canSendMail])
        return [self sendErrorCode:MessageErrorCantSendMail toCallback:self.composeMailCallbackID];
    NSString* subject       = [options objectForKey:@"subject"];
    NSArray* toRecipients   = [options objectForKey:@"to"];
    NSArray* ccRecipients   = [options objectForKey:@"cc"];
    NSArray* bccRecipients  = [options objectForKey:@"bcc"];
    NSString* mailBody      = [options objectForKey:@"body"];
    NSNumber* isHTML        = [options objectForKey:@"html"];
    MFMailComposeViewController* mc = [MFMailComposeViewController new];
    mc.mailComposeDelegate = self;
    [mc setSubject:subject];
    [mc setToRecipients:toRecipients];
    [mc setCcRecipients:ccRecipients];
    [mc setBccRecipients:bccRecipients];
    [mc setMessageBody:mailBody isHTML:(isHTML == nil ? NO : [isHTML boolValue])];
    [self.viewController presentViewController:mc animated:YES completion:nil];
}

- (void) canSendText:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    NSString* callbackID = [arguments objectAtIndex:0];
    if ([MFMessageComposeViewController canSendText])
        [self sendSuccessResult:nil toCallback:callbackID];
    else
        [self sendErrorCode:MessageErrorCantSendText toCallback:callbackID];
}

- (void) canSendMail:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    NSString* callbackID = [arguments objectAtIndex:0];
    if ([MFMailComposeViewController canSendMail])
        [self sendSuccessResult:nil toCallback:callbackID];
    else
        [self sendErrorCode:MessageErrorCantSendMail toCallback:callbackID];
}

#pragma mark - <MFMessageComposeViewControllerDelegate>

- (void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self.viewController dismissViewControllerAnimated:YES completion:^{
        if (result == MessageComposeResultSent)
            [self sendSuccessResult:nil toCallback:self.composeMessageCallbackID];
        else if (result == MessageComposeResultCancelled)
            [self sendErrorCode:MessageErrorCancelled toCallback:self.composeMessageCallbackID];
        else if (result == MessageComposeResultFailed)
            [self sendErrorCode:MessageErrorFailed toCallback:self.composeMessageCallbackID];
        else
            [self sendErrorCode:MessageErrorUnknown toCallback:self.composeMessageCallbackID];
    }];
}

#pragma mark - <MFMailComposeViewControllerDelegate>

- (void) mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self.viewController dismissViewControllerAnimated:YES completion:^{
        if (result == MFMailComposeResultSent || result == MFMailComposeResultSaved) {
            [self sendSuccessResult:nil toCallback:self.composeMailCallbackID];
            return;
        }
        MessageError errcode = MessageErrorUnknown;
        if (error != nil && [error.domain isEqualToString:MFMailComposeErrorDomain]) {
            if (error.code == MFMailComposeErrorCodeSaveFailed)
                errcode = MessageErrorCouldNotSaveMailToDrafts;
            else if (error.code == MFMailComposeErrorCodeSendFailed)
                errcode = MessageErrorCouldNotSendMail;
        }
        else if (result == MFMailComposeResultCancelled)
            errcode = MessageErrorCancelled;
        else if (result == MFMailComposeResultFailed)
            errcode = MessageErrorFailed;
        [self sendErrorCode:errcode toCallback:self.composeMailCallbackID];
    }];
}

@end

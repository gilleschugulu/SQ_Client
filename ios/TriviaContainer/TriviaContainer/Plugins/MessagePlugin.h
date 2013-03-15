//
//  Message.h
//  TriviaSports
//
//  Created by Sergio Kunats on 6/12/12.
//  Copyright (c) 2012 Chugulu. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "BasePlugin.h"

typedef enum {
    MessageErrorCantSendText            = 0,
    MessageErrorCancelled               = 1,
    MessageErrorFailed                  = 2,
    MessageErrorUnknown                 = 3,
    MessageErrorCantSendMail            = 4,
    MessageErrorCouldNotSendMail        = 5,
    MessageErrorCouldNotSaveMailToDrafts= 6
} MessageError;

@interface MessagePlugin : BasePlugin <MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>

@end

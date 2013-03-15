//
//  JSConsoleViewController.m
//  TriviaSports
//
//  Created by Sergio Kunats on 10/1/12.
//  Copyright (c) 2012 Chugulu. All rights reserved.
//

#import "JSConsoleViewController.h"
#import <QuartzCore/QuartzCore.h>

const CGFloat kConsoleHeight = 170.0;

@interface JSConsoleViewController ()

@property (nonatomic, assign) NSUInteger historyIndex;
@property (nonatomic, strong) NSMutableArray* commandHistory;
@property (nonatomic, assign) CGRect parentFrame;
@property (nonatomic, strong) UITextView* consoleInput;
@property (nonatomic, weak) UIWebView* targetWebView;
@property (nonatomic, strong) UIButton* toggleButton;

@end

@implementation JSConsoleViewController

- (id) initWithFrame:(CGRect)parentFrame targetWebView:(UIWebView *)targetView {
    if ((self = [super initWithNibName:nil bundle:nil])) {
        self.parentFrame    = parentFrame;
        self.targetWebView  = targetView;
        self.commandHistory = [NSMutableArray new];
        self.historyIndex   = 0;
    }
    return self;
}

#pragma mark - Console View Creation

- (UIButton *) newButtonWithTitle:(NSString *)title
                            frame:(CGRect)frame
                           action:(SEL)action
                       targetView:(UIView *)targetView
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = frame;
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [targetView addSubview:button];
    return button;
}

- (void) initHistoryButtons:(UIView *)targetView {
    // prev
    [self newButtonWithTitle:@"<"
                       frame:CGRectMake(0, 95, 50, 40)
                      action:@selector(historyPrev)
                  targetView:targetView];

    // next
    [self newButtonWithTitle:@">"
                       frame:CGRectMake(55, 95, 50, 40)
                      action:@selector(historyNext)
                  targetView:targetView];
}

- (void) initToggleButton:(UIView *)targetView {
    self.toggleButton = [self newButtonWithTitle:@">"
                                           frame:CGRectMake(0, kConsoleHeight - 30.0, 30.0, 30.0)
                                          action:@selector(toggleConsole)
                                      targetView:targetView];
    self.toggleButton.alpha = 0.5;
}

- (void) initSomethingButtons:(UIView *)targetView {
    [self newButtonWithTitle:@"EXECUTE"
                       frame:CGRectMake(0, 0, 100, 40)
                      action:@selector(executeCode)
                  targetView:targetView];

    [self newButtonWithTitle:@"CLEAR"
                       frame:CGRectMake(0, 45, 100, 40)
                      action:@selector(clearConsole)
                  targetView:targetView];
}

- (void) initInput:(UIView *)targetView {
    self.consoleInput = [[UITextView alloc] initWithFrame:CGRectMake(110, 0, targetView.frame.size.width - 120, targetView.frame.size.height - 20)];
    self.consoleInput.font                   = [UIFont systemFontOfSize:24];
    self.consoleInput.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.consoleInput.autocorrectionType     = UITextAutocorrectionTypeNo;
    self.consoleInput.keyboardAppearance     = UIKeyboardAppearanceAlert;
    self.consoleInput.layer.borderColor      = [UIColor grayColor].CGColor;
    self.consoleInput.layer.borderWidth      = 1.0;
    self.consoleInput.layer.cornerRadius     = 5.0;
    [targetView addSubview:self.consoleInput];
}

- (void) loadView {
    UIView* cView = [[UIView alloc] initWithFrame:CGRectMake(5.0, -(kConsoleHeight - 20.0), _parentFrame.size.width, kConsoleHeight)];

    [self initSomethingButtons:cView];
    [self initHistoryButtons:cView];
    [self initToggleButton:cView];
    [self initInput:cView];

    self.view = cView;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    // prevents invisible text
    CGRect tempFrame = self.consoleInput.frame;
    [self.consoleInput setFrame:CGRectZero];
    [self.consoleInput setFrame:tempFrame];
}

#pragma mark - Command History

- (void) historyAdd:(NSString *)command {
    NSString* lastCommand = [self.commandHistory lastObject];
    if (lastCommand != nil && [lastCommand isEqualToString:command])
        return;
    [self.commandHistory addObject:command];
    self.historyIndex = [self.commandHistory count] - 1;
}

- (void) historyPrev {
    if (self.historyIndex < 1)
        return;
    if ([self.commandHistory count] < 1)
        return;
    self.historyIndex--;
    self.consoleInput.text = [self.commandHistory objectAtIndex:self.historyIndex];
}

- (void) historyNext {
    NSUInteger historyLength = [self.commandHistory count];

    if (historyLength <= 1 || self.historyIndex >= historyLength - 1) {
        self.historyIndex = historyLength;
        [self clearConsole];
        return;
    }
    self.historyIndex++;
    self.consoleInput.text = [self.commandHistory objectAtIndex:self.historyIndex];
}

#pragma mark - Console

- (void) executeCode {
    [self.consoleInput resignFirstResponder];
    if (![self.consoleInput hasText] || self.targetWebView == nil)
        return;
    NSLog(@"\nEXECUTING JS\n%@\n/EXECUTING JS", self.consoleInput.text);
    [self historyAdd:self.consoleInput.text];
    [self.targetWebView stringByEvaluatingJavaScriptFromString:self.consoleInput.text];
}

- (void) clearConsole {
    self.consoleInput.text = @"";
}

- (void) toggleConsole {
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = self.view.frame;
        if (frame.origin.y < 0) {
            frame.origin.y = 5;
            [self.consoleInput becomeFirstResponder];
            [self.toggleButton setTitle:@"^" forState:UIControlStateNormal];
        } else {
            frame.origin.y = -(kConsoleHeight - 20.0);
            [self.consoleInput resignFirstResponder];
            [self.toggleButton setTitle:@">" forState:UIControlStateNormal];
        }
        self.view.frame = frame;
    }];
}

@end

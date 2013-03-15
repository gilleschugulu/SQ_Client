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
//  MainViewController.h
//  TriviaSports
//
//  Created by Sergio Kunats on 5/14/12.
//  Copyright Chugulu 2012. All rights reserved.
//

#import "ViewController.h"

#ifdef JS_CONSOLE
#import "JSConsoleViewController.h"

@interface ViewController ()

@property (nonatomic, strong) JSConsoleViewController* jsConsole;

@end
#endif

@interface CDVViewController (show_splash)

- (void) showSplashScreen;

@end

@implementation ViewController

#ifdef JS_CONSOLE

- (void) initJSConsole {
    self.jsConsole = [[JSConsoleViewController alloc] initWithFrame:CGRectMake(5, 5,
                                                                               MAX(self.webView.frame.size.width, self.webView.frame.size.height), 70)
                                                      targetWebView:self.webView];
    [self.webView addSubview:self.jsConsole.view];
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void) toggleJSConsole:(UITapGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateRecognized)
        return;

    if (self.jsConsole) {
        [self.jsConsole.view removeFromSuperview];
        self.jsConsole = nil;
    }
    else
        [self initJSConsole];
}
#endif

#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
    self.useSplashScreen = YES;


#ifdef JS_CONSOLE 
    UITapGestureRecognizer* tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleJSConsole:)];
    tapper.numberOfTapsRequired     = 3;
    tapper.numberOfTouchesRequired  = 3;
    tapper.delegate = self;
    [self.webView addGestureRecognizer:tapper];
#endif
}

- (void) showSplashScreen {
    [super showSplashScreen];
    CGPoint spinnerCenter = self.activityView.center;
    spinnerCenter.x += self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ? 100.0f : -100.0f;
    self.activityView.center = spinnerCenter;
}

@end

//
//  PermaKeyboardPlugin.m
//  TriviaContainer
//
//  Created by Sergio Kunats on 2/19/13.
//  Copyright (c) 2013 Chugulu. All rights reserved.
//

#import "PermaKeyboardPlugin.h"

@interface PermaKeyboardPlugin ()

@property (nonatomic, strong) UITextField* permaTextField;
@property (nonatomic, copy) NSString* eventJSFormat;
@property (nonatomic, assign) BOOL enabled;

@end

@implementation PermaKeyboardPlugin

@synthesize permaTextField;
@synthesize eventJSFormat;
@synthesize enabled;

- (void) setEnabled:(BOOL)enable
{
    if (self.permaTextField) {
        self.permaTextField.hidden = !enable;
        self.permaTextField.text = nil;
    }
}

- (BOOL) enabled
{
    if (self.permaTextField)
        return !self.permaTextField.hidden;
    return NO;
}

-(void)show:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    //Get text field coordinate from webview. - You should do this after the webview gets loaded
    //myCustomDiv is a div in the html that contains the textField.
    CGRect frame = CGRectMake([[options objectForKey:@"left"] floatValue],
                              [[options objectForKey:@"top"] floatValue],
                              [[options objectForKey:@"width"] floatValue],
                              [[options objectForKey:@"height"] floatValue]);
    self.eventJSFormat = options[@"eventJS"];
    if (self.permaTextField == nil)
        self.permaTextField = [[UITextField alloc] initWithFrame:frame];
    if ([options objectForKey:@"placeholder"])
        self.permaTextField.placeholder = [options objectForKey:@"placeholder"];
    NSString* font = [options objectForKey:@"font"];
    NSString* fontSize = [options objectForKey:@"fontSize"];
    if (font)
        self.permaTextField.font = [UIFont fontWithName:font size:[fontSize floatValue]];
    [self.webView addSubview:self.permaTextField];
    self.permaTextField.delegate = self;
    if (options[@"disabled"])
        [self setEnabled:NO];
    else
        [self.permaTextField becomeFirstResponder];
}

- (void) hide:(NSMutableArray*)arguments withDict:(NSDictionary*)options {
    UITextField* tmp = self.permaTextField;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    self.permaTextField = nil;
    [tmp resignFirstResponder];
    [tmp removeFromSuperview];
}

- (void) setEnabled:(NSMutableArray*)arguments withDict:(NSDictionary*)options {
    if (arguments.count > 1)
        self.enabled = [arguments[1] boolValue];
}

- (void) empty:(NSMutableArray*)arguments withDict:(NSDictionary*)options {
    if (self.permaTextField)
        self.permaTextField.text = nil;
}

- (void) getText:(NSMutableArray*)arguments withDict:(NSDictionary*)options {
    [self sendSuccessResult:self.permaTextField.text toCallback:arguments[0]];
}


- (void) setText:(NSMutableArray*)arguments withDict:(NSDictionary*)options {
    if (arguments.count > 1)
        self.permaTextField.text = arguments[1];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //here you create your request to the server
    if (self.permaTextField && self.enabled)
    {
        NSString* escaped = [self.permaTextField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString* js = [NSString stringWithFormat:self.eventJSFormat, escaped];
        [self.webView stringByEvaluatingJavaScriptFromString:js];
    }
    return (self.permaTextField == nil);
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    return self.enabled;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    //here you create your request to the server
    return (self.permaTextField == nil);
}

@end

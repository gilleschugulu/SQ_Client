//
//  XitiAnalyticsPlugin.m
//  TriviaStars
//
//  Created by Sergio Kunats on 10/24/12.
//  Copyright (c) 2012 Chugulu. All rights reserved.
//

#import "XitiAnalyticsPlugin.h"
#import "ATParams.h"
#import "ATTag.h"

@implementation XitiAnalyticsPlugin

- (void) page:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    NSString* level2    = [options objectForKey:@"level2"];
    NSDictionary* extra = [options objectForKey:@"extra"];

    ATParams* tag = [ATParams new];

    [tag setPage:[options objectForKey:@"page"]];

    for (NSString* key in extra)
        [tag setCustomCritera:key andValue:[extra objectForKey:key]];

    if (level2)
        [tag setLevel2:level2];

    [tag xt_sendTag];
}

- (void) click:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    ATParams* tag = [ATParams new];

    int clickType = action;
    NSString* ctype = [options objectForKey:@"type"];
    if ([ctype isEqualToString:@"N"])
        clickType = navigation;
    else if ([ctype isEqualToString:@"S"])
        clickType = exitPage;
    else if ([ctype isEqualToString:@"T"])
        clickType = download;

    [tag xt_click:[options objectForKey:@"level2"]
     andClickName:[options objectForKey:@"click"]
     andClickType:clickType];

    [tag xt_sendTag];
}

- (void) transaction:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    ATParams *tag = [ATParams new];

    [tag setLevel2:[options objectForKey:@"level2"]];
    [tag setOrderId:[options objectForKey:@"orderId"]];
    [tag setOrderPriceWithTaxes:[options objectForKey:@"totalPrice"]];
    [tag setOrderPrice:[options objectForKey:@"totalPrice"]];
    [tag setStatus:@"3"];

    for (NSDictionary* item in [options objectForKey:@"items"]) {
        [tag xt_addProduct:[item objectForKey:@"productId"]
               andQuantity:[item objectForKey:@"quantity"]
       andPriceWithoutTaxe:[item objectForKey:@"priceNoTax"]
         andPriceWithTaxes:[item objectForKey:@"price"]
                  andTaxes:[item objectForKey:@"tax"]
    andDiscountBeforeTaxes:@""
      andDiscountWithTaxes:@""
           andDiscountCode:@""];
    }
    [tag xt_sendTag];
}

@end

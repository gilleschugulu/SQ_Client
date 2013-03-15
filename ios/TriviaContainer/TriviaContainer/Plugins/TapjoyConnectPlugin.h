//
//  TapjoyConnectPlugin.h
//  TriviaStars
//
//  Created by Sergio Kunats on 9/5/12.
//  Copyright (c) 2012 Chugulu. All rights reserved.
//

#import "BasePlugin.h"
#import "TapjoyConnect.h"

@interface TapjoyConnectPlugin : BasePlugin <TJCVideoAdDelegate>
{
	NSString *connectCallbackID;			/*!< The callback ID for the Tapjoy Connect call. */
	NSString *featuredAppCallbackID;		/*!< The callback ID for Featured App. */
	NSString *tapPointsCallbackID;		/*!< The callback ID for retrieving Tap Points. */
	NSString *spendTapPointsCallbackID;	/*!< The callback ID for spending Tap Points. */
	NSString *awardTapPointsCallbackID;	/*!< The callback ID for awarding Tap Points. */
}

@property (nonatomic, copy) NSString* connectCallbackID;
@property (nonatomic, copy) NSString* featuredAppCallbackID;
@property (nonatomic, copy) NSString* tapPointsCallbackID;
@property (nonatomic, copy) NSString* spendTapPointsCallbackID;
@property (nonatomic, copy) NSString* awardTapPointsCallbackID;
@property (nonatomic, copy) NSString* offersCallbackID;

- (void)requestTapjoyConnect:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)setUserID:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)actionComplete:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)showOffers:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)showOffersWithCurrencyID:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)getTapPoints:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)spendTapPoints:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)awardTapPoints:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)getFullScreenAd:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)getFullScreenAdWithCurrencyID:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)showFullScreenAd:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)initVideoAd:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)setVideoCacheCount:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end

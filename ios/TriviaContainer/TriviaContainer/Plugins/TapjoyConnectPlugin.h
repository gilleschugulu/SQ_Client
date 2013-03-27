//
//  TapjoyConnectPlugin.h
//  TriviaStars
//
//  Created by Sergio Kunats on 9/5/12.
//  Copyright (c) 2012 Chugulu. All rights reserved.
//

#import "BasePlugin.h"
#import "TapjoyConnect.h"

@interface TapjoyConnectPlugin : BasePlugin <TJCAdDelegate, TJCVideoAdDelegate>
{
}

@property (nonatomic, retain) NSMutableDictionary *keyFlagValueDict;
@property (nonatomic, copy) NSString* connectCallbackID;            /*!< The callback ID for the Tapjoy Connect call. */
@property (nonatomic, copy) NSString* featuredAppCallbackID;        /*!< The callback ID for Featured App. */
@property (nonatomic, copy) NSString* fullScreenAdCallbackID;       /*!< The callback ID for Full Screen Ad. */
@property (nonatomic, copy) NSString* tapPointsCallbackID;          /*!< The callback ID for retrieving Tap Points. */
@property (nonatomic, copy) NSString* spendTapPointsCallbackID;     /*!< The callback ID for spending Tap Points. */
@property (nonatomic, copy) NSString* awardTapPointsCallbackID;     /*!< The callback ID for awarding Tap Points. */
@property (nonatomic, copy) NSString* dailyRewardAdCallbackID;      /*!< The callback ID for Daily Reward Ad. */
@property (nonatomic, copy) NSString* videoAdDelegateCallbackID;    /*!< The callback ID for Video Ad Delegate. */
@property (nonatomic, copy) NSString* displayAdCallbackID;          /*!< The callback ID for Display Ad. */
@property (nonatomic, copy) NSString* offersCallbackID;             /*!< The callback ID for Offer Wall. */
@property (nonatomic, assign, getter=shouldDisplayAdAutoRefresh) BOOL enableDisplayAdAutoRefresh;
@property (nonatomic, copy) NSString* displayAdSize;
@property (nonatomic, assign) CGRect displayAdFrame;

- (BOOL)hasKeyFlag;

- (void)setFlagKeyValue:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)requestTapjoyConnect:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)setUserID:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)actionComplete:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)showOffers:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)showOffersWithCurrencyID:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)getTapPoints:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)spendTapPoints:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)awardTapPoints:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)getFeaturedApp:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)getFeaturedAppWithCurrencyID:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)setFeaturedAppDisplayCount:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)showFeaturedAppFullScreenAd:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)getFullScreenAd:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)getFullScreenAdWithCurrencyID:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)showFullScreenAd:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)getDailyRewardAd:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)getDailyRewardAdWithCurrencyID:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)showDailyRewardAd:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)initVideoAd:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)setVideoCacheCount:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)setVideoAdDelegate:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)cacheVideos:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)sendIAPEvent:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)getDisplayAd:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)showDisplayAd:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)hideDisplayAd:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)enableDisplayAdAutoRefresh:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)moveDisplayAd:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)setDisplayAdSize:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end

//+---------------------------------------------------------------------------+
//| Copyright (c) 2012 AT Internet.											  |
//| All rights reserved.                                                      |
//| For help with this library contact support@atinternet.com                 |
//| Version Tag 1.3.001                                                       |
//+---------------------------------------------------------------------------+


#import <Foundation/Foundation.h>
#import <sqlite3.h>

typedef enum {
	OfflineModeNever,
	OfflineModeRequired,
	OfflineModeAlways,
} OfflineMode;

@interface ATTag : NSObject{
	NSString *subdomain;
	NSString *siteId;
	NSString *uniqueId;
	NSDictionary *phoneInfos;
	NSOperationQueue *operationQueue;
	OfflineMode offlineMode;
	BOOL AT_debug;
    BOOL bgTaskEnabled;
    UIBackgroundTaskIdentifier bgTask;
}
@property (nonatomic, retain) NSString *subdomain;
@property (nonatomic, retain) NSString *siteId;
@property (nonatomic, retain) NSDictionary *phoneInfos;
@property (retain,nonatomic) 	NSOperationQueue *operationQueue;
@property (nonatomic) OfflineMode offlineMode;
@property (nonatomic, assign) BOOL AT_debug;
@property (nonatomic, assign) BOOL bgTaskEnabled;
@property (nonatomic, assign) UIBackgroundTaskIdentifier bgTask;
@property (nonatomic, retain) NSString *uniqueId;
#define ATTagInfoSubDomain	@"ATTagInfoSubDomain"
#define ATTagInfoSiteId		@"ATTagInfoSiteId"

+ (ATTag *)sharedATTag;
- (NSString *)getUniqueId;
- (ATTag *) initWithATSubDomain:(NSString *)subDomain  siteId:(NSString *)siteIdIn;
- (void) tagPage:(NSString *)page;
- (void) launchRequest:(NSString *)toAppend;
- (void) tagPage:(NSString*) page withDictionary:(NSDictionary *)aDictionary;
- (void) tagWithDefaultPath:(NSString *)defaultPath otherParameters:(NSDictionary *)aDictionary;
- (void) initDatabase;
- (void) saveOfflineHit:(NSString*)url;
- (void) loadOfflineHits;
- (void) setOfflineMode:(OfflineMode)offmode;
- (void) loadOfflineHitsToOperationQueueSendNow:(NSMutableArray*)hitsArray;
- (void) sendNow;
- (void) setDebug:(BOOL)debug;
- (int) getNbHitsOffline;
- (void) deleteHitsOffline:(int)nbToDel;
- (NSDate *) getDateFromHit:(int)numHit;
- (void) setBgTaskEnabled:(BOOL)bgTaskEnabled;
@end

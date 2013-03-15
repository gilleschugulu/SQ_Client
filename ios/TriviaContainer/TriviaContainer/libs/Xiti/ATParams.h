//+---------------------------------------------------------------------------+
//| Copyright (c) 2012 AT Internet.											  |
//| All rights reserved.                                                      |
//| For help with this library contact support@atinternet.com                 |
//| Version Tag 1.3.001                                                       |
//+---------------------------------------------------------------------------+


#import <Foundation/Foundation.h>
#define kATAudioType		@"audio"
#define kATVideoType		@"video"
#define kATAnimationType	@"animation"

	//_________________________________________________________________________________________________
typedef enum {
	navigation= 0,
	download = 1,
	exitPage = 2,
	action = 3,
} clicType;

	//_________________________________________________________________________________________________
typedef enum {
	mediaTypeAudio= 0,
	mediaTypeVideo = 1,
	mediaTypeAnimation = 2,
} mediaType;

	//_________________________________________________________________________________________________
typedef enum{
	Play,
	Pause,
	Stop,
	Forward,
	Backward,
	Share,
	Email,
	Favor,
	DownloadAct,
	Move,
	Info,
	Perso,
	Refresh
}mediaAction;

	//_________________________________________________________________________________________________
typedef enum{
	quality22khz = 1,
	quality44khz = 2,
	quality32khz = 3,
	quality70khz = 4,
}mediaQuality;

	//_________________________________________________________________________________________________
typedef enum{
	stream64kpbs = 1,
	stream128kpbs = 2,
	stream160kpbs = 3,
	stream192kpbs = 4,
	stream224kpbs = 5,
	stream256kpbs = 6,
	stream320kpbs = 7,
	stream22kpbs = 8,
	stream96kpbs = 9,
	stream112kpbs = 10,
	stream300kpbs = 11,
	stream500kpbs = 12,
	stream1000kpbs = 13,
}mediaStream;

	//_________________________________________________________________________________________________
typedef enum{
	sourceInt,
	sourceExt
}mediaSource;

	//_________________________________________________________________________________________________
typedef enum{
	clip,
	live
}mediaSourceType;

typedef enum{
	mp3 = 1,
	wma = 2,
	wav = 3,
	aiff = 4,
	aac = 5,
	mpeg = 6,
	flv = 7,
	swf = 8,
	mp4 = 9,
	avi = 10,
	mkv = 11,
	wmv = 12,
	mp3G = 13,
	rm = 14,
	rmvb = 15,
	mov = 16,
	ogg = 17
}mediaExtension;


@interface ATParams : NSObject {
	NSMutableDictionary *params;
	NSInteger countProducts;
	NSTimer * refreshTimer;
	float rfshTime;
}

-(id)init;
-(void)setLocation:(double)latitude andLongitude:(double)longitude;
-(void)setType:(NSString*)type;
-(void)setLevel2:(NSString*)level2;
-(void)setPageId:(NSString*)pageId andPageChapter:(NSString*)pageChapter andPageDate:(NSString*)pageDate;
-(void)put:(NSString*)key andValue:(NSString*)value;
-(void)setCustomCritera:(NSString*)idCritera andValue:(NSString*)valueCritera;
-(void)setCustomForm:(NSString*)idFormCritera andValue:(NSString*)valueForm;
-(void)setSearchEngineKeywords:(NSString*)keywords andNumberOfResults:(NSString*)number;
-(void)setClic:(clicType)typeIn;
-(void)setMediaType:(mediaType)type;
-(void)setMediaAction:(mediaAction)action;
-(void)setMediaQuality:(mediaQuality)quality;
-(void)setMediaStream:(mediaStream)stream;
-(void)setMediaSource:(mediaSource)source;
-(void)setMediaStreamType:(mediaSourceType)type;
-(void)setMediaSize:(NSString*)size;
-(void)setMediaDuration:(NSString*)duration;
-(void)setCartId:(NSString*)cartId;
-(void)setOrderId:(NSString*)orderId;
-(void)setOrderPrice:(NSString*)price;
-(void)setOrderPriceWithoutTaxes:(NSString*)priceWithoutTaxes;
-(void)setOrderPriceWithTaxes:(NSString*)priceWithTaxes;
-(void)setShippingCostWithoutTaxe:(NSString*)shippingWithoutTaxe andWithTaxes:(NSString*)shippingWithTaxes;
-(void)setTaxes:(NSString*)taxes;
-(void)setPaymentMethod:(NSString*)PaymentMethod;
-(void)setDelivery:(NSString*)delivery;
-(void)setStatus:(NSString*)status;
-(void)setNewCustomer:(BOOL)NewCustomer;
-(void)setPromotionCode:(NSString*)promotionCode;
-(void)setDiscountWithTaxes:(NSString*)dsc andWithoutTaxes:(NSString*)dscht;
-(void)setDiscountForProduct:(NSString*)idProduct andDiscountWithTaxes:(NSString*)dsc andDiscountWithoutTaxe:(NSString*)dscht andDiscountCode:(NSString*)discountCode;
-(void)xt_click:(NSString*)level2 andClickName:(NSString*)click_name andClickType:(clicType)typeIn;
-(void)xt_sendTag;
-(void)setPage:(NSString*)page;
-(void)	 xt_ad:(BOOL)showOrClick
  andIsIntOrExt:(BOOL)IntOrExt 
  andIdCampaign:(NSString*)idCampaign 
  andIdCreation:(NSString*) creation 
	 andVariant:(NSString*)variant
	  andFormat:(NSString*)format
andEmplacement:(NSString*)adEmplacement
andEmplacementDetail:(NSString*)adEmplacementDetail
   andAnnonceur:(NSString*)annonceur
	andIdProduct:(NSString*)idProduct;
-(void)xt_rm:(mediaType)media_type 
	 andLevel2:(NSString*)level2 
 andPlayerId:(NSString*)playerId
  andMediaName:(NSString*)mediaName 
	 andAction:(mediaAction)media_action
andRefreshTime:(NSString*)refreshTime
andMediaDuration:(NSString*)mediaDuration
andMediaQuality:(mediaQuality)media_quality
andMediaStream:(mediaStream)media_stream
andMediaSource:(mediaSource)media_source
 andLiveOrClip:(BOOL)liveOrClip
  andMediaSize:(NSString*)mediaSize
andMediaExtension:(mediaExtension)media_extension;
-(void)xt_addProduct:(NSString*)productName
		 andQuantity:(NSString*)quantity
 andPriceWithoutTaxe:(NSString*)price
   andPriceWithTaxes:(NSString*)priceTaxes
			andTaxes:(NSString*)taxes
andDiscountBeforeTaxes:(NSString*)dsc
andDiscountWithTaxes:(NSString*)dscc
	 andDiscountCode:(NSString*)discountCode;
@property (retain,nonatomic) 	NSMutableDictionary *params;
@property (retain,nonatomic) 	NSTimer *refreshTimer;
@end



// Autogenerated from Pigeon (v0.1.17), do not edit directly.
// See also: https://pub.dev/packages/pigeon
#import <Foundation/Foundation.h>
@protocol FlutterBinaryMessenger;
@class FlutterError;
@class FlutterStandardTypedData;

NS_ASSUME_NONNULL_BEGIN

@class FLTYenepayPaymentRequest;

@interface FLTYenepayPaymentRequest : NSObject
@property(nonatomic, copy, nullable) NSString * merchantCode;
@property(nonatomic, copy, nullable) NSString * merchantOrderId;
@property(nonatomic, copy, nullable) NSString * ipnUrl;
@property(nonatomic, copy, nullable) NSString * returnUrl;
@property(nonatomic, strong, nullable) NSNumber * tax1;
@property(nonatomic, strong, nullable) NSNumber * tax2;
@property(nonatomic, strong, nullable) NSNumber * deliveryFee;
@property(nonatomic, strong, nullable) NSNumber * handlingFee;
@property(nonatomic, strong, nullable) NSNumber * discount;
@property(nonatomic, strong, nullable) NSNumber * isUseSandboxEnabled;
@property(nonatomic, strong, nullable) NSArray * items;
@end

@protocol FLTYenePayApi
-(void)requestPayment:(FLTYenepayPaymentRequest*)input error:(FlutterError *_Nullable *_Nonnull)error;
@end

extern void FLTYenePayApiSetup(id<FlutterBinaryMessenger> binaryMessenger, id<FLTYenePayApi> _Nullable api);

NS_ASSUME_NONNULL_END

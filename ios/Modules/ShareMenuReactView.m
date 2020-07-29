#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(ShareMenuReactView, NSObject)

RCT_EXTERN_METHOD(data:(RCTPromiseResolveBlock)resolver reject:(RCTPromiseRejectBlock)rejecter)

RCT_EXTERN_METHOD(dismissExtension:(NSString *)error)

RCT_EXTERN_METHOD(openApp)

RCT_EXTERN_METHOD(continueInApp:(NSDictionary *)extraData)

@end

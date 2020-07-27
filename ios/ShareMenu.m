#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_MODULE(ShareMenu, RCTEventEmitter)

RCT_EXTERN_METHOD(getSharedText:(RCTResponseSenderBlock)callback)

@end

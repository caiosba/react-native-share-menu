//
//  ShareMenuManager.m
//  react-native-share-menu
//
//  Created by Gustavo Parreira on 26/07/2020.
//

#import "ShareMenuManager.h"
#import "RNShareMenu-Swift.h"

#import <React/RCTLinkingManager.h>

@implementation ShareMenuManager

+ (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    [ShareMenuMessenger shareWithApplication:app openUrl:url options:options];
    return [RCTLinkingManager application:app openURL:url options:options];
}

@end

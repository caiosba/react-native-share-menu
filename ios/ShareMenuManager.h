//
//  ShareMenuManager.h
//  react-native-share-menu
//
//  Created by Gustavo Parreira on 26/07/2020.
//

@interface ShareMenuManager : NSObject

+ (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options;

@end

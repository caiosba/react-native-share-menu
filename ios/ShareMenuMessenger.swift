//
//  ShareMenuMessenger.swift
//  RNShareMenu
//
//  This class handles all messages from Obj-C to the main ShareMenu.swift file
//
//  Created by Gustavo Parreira on 27/07/2020.
//

@objc(ShareMenuMessenger)
open class ShareMenuMessenger: NSObject {
    @objc public static func share(
        application app: UIApplication,
        openUrl url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any]
    ) {
        ShareMenu.messageShare(application: app, openUrl: url, options: options)
    }
}

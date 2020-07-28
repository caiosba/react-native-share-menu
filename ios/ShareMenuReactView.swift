//
//  ShareMenuReactView.swift
//  RNShareMenu
//
//  Created by Gustavo Parreira on 28/07/2020.
//

import MobileCoreServices

@objc(ShareMenuReactView)
public class ShareMenuReactView: NSObject {
    static var extensionContext: NSExtensionContext? = nil
    
    @objc
    static public func requiresMainQueueSetup() -> Bool {
        return false
    }
    
    public static func attachExtensionContext(_ context: NSExtensionContext!) {
        guard (ShareMenuReactView.extensionContext == nil) else { return }
        
        ShareMenuReactView.extensionContext = context
    }
    
    public static func detachExtensionContext() {
        ShareMenuReactView.extensionContext = nil
    }
    
    @objc
    func dismissExtension() {
        ShareMenuReactView.extensionContext!
            .completeRequest(returningItems: [], completionHandler: nil)
    }
    
    @objc(data:reject:)
    func data(_
            resolve: @escaping RCTPromiseResolveBlock,
            reject: @escaping RCTPromiseRejectBlock) {
        extractDataFromContext(context: ShareMenuReactView.extensionContext!) { (data, mimeType, error) in
            guard (error == nil) else {
                reject("error", error?.description, nil)
                return
            }
            
            resolve([MIME_TYPE_KEY: mimeType, DATA_KEY: data])
        }
    }
    
    func extractDataFromContext(context: NSExtensionContext, withCallback callback: @escaping (String?, String?, NSException?) -> Void) {
        let item:NSExtensionItem! = context.inputItems.first as? NSExtensionItem
        let attachments:[AnyObject]! = item.attachments

        var urlProvider:NSItemProvider! = nil
        var imageProvider:NSItemProvider! = nil
        var textProvider:NSItemProvider! = nil

        for provider in attachments {
            if provider.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
                urlProvider = provider as? NSItemProvider
                break
            } else if provider.hasItemConformingToTypeIdentifier(kUTTypeText as String) {
                textProvider = provider as? NSItemProvider
                break
            } else if provider.hasItemConformingToTypeIdentifier(kUTTypeImage as String) {
                imageProvider = provider as? NSItemProvider
                break
            }
        }

        if (urlProvider != nil) {
            urlProvider.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil) { (item, error) in
                let url: URL! = item as? URL

                callback(url.absoluteString, "text/plain", nil)
            }
        } else if (imageProvider != nil) {
            imageProvider.loadItem(forTypeIdentifier: kUTTypeImage as String, options: nil) { (item, error) in
                let url: URL! = item as? URL

                callback(url.absoluteString, self.extractMimeType(from: url), nil)
            }
        } else if (textProvider != nil) {
            textProvider.loadItem(forTypeIdentifier: kUTTypeText as String, options: nil) { (item, error) in
                let text:String! = item as? String

                callback(text, "text/plain", nil)
            }
        } else {
            callback(nil, nil, NSException(name: NSExceptionName(rawValue: "Error"), reason:"couldn't find provider", userInfo:nil))
        }
    }
    
    func extractMimeType(from url: URL) -> String {
      let fileExtension: CFString = url.pathExtension as CFString
      guard let extUTI = UTTypeCreatePreferredIdentifierForTag(
              kUTTagClassFilenameExtension,
              fileExtension,
              nil
      )?.takeUnretainedValue() else { return "" }

      guard let mimeUTI = UTTypeCopyPreferredTagWithClass(extUTI, kUTTagClassMIMEType)
      else { return "" }

      return mimeUTI.takeUnretainedValue() as String
    }
}

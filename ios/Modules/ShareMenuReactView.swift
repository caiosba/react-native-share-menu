//
//  ShareMenuReactView.swift
//  RNShareMenu
//
//  Created by Gustavo Parreira on 28/07/2020.
//

import MobileCoreServices

@objc(ShareMenuReactView)
public class ShareMenuReactView: NSObject {
    static var viewDelegate: ReactShareViewDelegate?

    @objc
    static public func requiresMainQueueSetup() -> Bool {
        return false
    }

    public static func attachViewDelegate(_ delegate: ReactShareViewDelegate!) {
        guard (ShareMenuReactView.viewDelegate == nil) else { return }

        ShareMenuReactView.viewDelegate = delegate
    }

    public static func detachViewDelegate() {
        ShareMenuReactView.viewDelegate = nil
    }

    @objc(dismissExtension:)
    func dismissExtension(_ error: String?) {
        guard let extensionContext = ShareMenuReactView.viewDelegate?.loadExtensionContext() else {
            print("Error: \(NO_EXTENSION_CONTEXT_ERROR)")
            return
        }

        if error != nil {
            let exception = NSError(
                domain: Bundle.main.bundleIdentifier!,
                code: DISMISS_SHARE_EXTENSION_WITH_ERROR_CODE,
                userInfo: ["error": error!]
            )
            extensionContext.cancelRequest(withError: exception)
            return
        }

        extensionContext.completeRequest(returningItems: [], completionHandler: nil)
    }

    @objc
    func openApp() {
        guard let viewDelegate = ShareMenuReactView.viewDelegate else {
            print("Error: \(NO_DELEGATE_ERROR)")
            return
        }

        viewDelegate.openApp()
    }

    @objc(continueInApp:)
    func continueInApp(_ extraData: [String:Any]?) {
        guard let viewDelegate = ShareMenuReactView.viewDelegate else {
            print("Error: \(NO_DELEGATE_ERROR)")
            return
        }

        let extensionContext = viewDelegate.loadExtensionContext()

        guard let item = extensionContext.inputItems.first as? NSExtensionItem else {
            print("Error: \(COULD_NOT_FIND_ITEM_ERROR)")
            return
        }

        viewDelegate.continueInApp(with: item, and: extraData)
    }

    @objc(data:reject:)
    func data(_
            resolve: @escaping RCTPromiseResolveBlock,
            reject: @escaping RCTPromiseRejectBlock) {
        guard let extensionContext = ShareMenuReactView.viewDelegate?.loadExtensionContext() else {
            print("Error: \(NO_EXTENSION_CONTEXT_ERROR)")
            return
        }

        extractDataFromContext(context: extensionContext) { (items, error) in
            guard (error == nil) else {
                reject("error", error?.description, nil)
                return
            }
            resolve(items)
        }
    }

    func extractDataFromContext(context: NSExtensionContext, withCallback callback: @escaping ([[String: String]], NSException?) -> Void) {
        let item:NSExtensionItem! = context.inputItems.first as? NSExtensionItem
        let attachments:[AnyObject]! = item.attachments
        var readCount = 0
        var type:String = ""
        var items = [[String: String]]()
        for provider in attachments {
            if provider.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
                type = kUTTypeURL as String
            } else if provider.hasItemConformingToTypeIdentifier(kUTTypeText as String) {
                type = kUTTypeText as String
            } else if provider.hasItemConformingToTypeIdentifier(kUTTypeImage as String) {
                type = kUTTypeImage as String
            } else if provider.hasItemConformingToTypeIdentifier(kUTTypeData as String) {
                type = kUTTypeData as String
            } else if provider.hasItemConformingToTypeIdentifier(kUTTypeVideo as String) {
                type = kUTTypeVideo as String
            }
            provider.loadItem(forTypeIdentifier: type , options: nil) { (item, error) in
                readCount = readCount + 1
                var mimeType:String? = nil
                var content:String? = nil
                if error != nil {
                    if readCount == attachments.count {
                        callback(items,nil)
                    }
                    return
                }
                if let url = item as? URL {
                    content = url.absoluteString
                    mimeType = self.extractMimeType(from: url)
                } else if let text = item as? String {
                    content = text
                    mimeType = "text/plain"
                } else if let image = item as? UIImage {
                    let imageData = image.pngData()
                    let fileExtension = "png"
                    let fileName = UUID().uuidString
                    if let hostAppId = Bundle.main.object(forInfoDictionaryKey: HOST_APP_IDENTIFIER_INFO_PLIST_KEY) as? String {
                        if let groupFileManagerContainer = FileManager.default
                                                      .containerURL(forSecurityApplicationGroupIdentifier: "group.\(hostAppId)") {
                            let filePath = groupFileManagerContainer
                                                  .appendingPathComponent("\(fileName).\(fileExtension)")
                            do {
                                try imageData?.write(to: filePath)
                                content = filePath.absoluteString
                                mimeType = "image/png"
                            }
                            catch (let error) {
                                print("Could not save image to \(filePath): \(error)")
                            }
                        }
                    }
                }
                if content != nil {
                    items.append(["data":content!, "mimeType":mimeType!])
                }
                if readCount == attachments.count {
                    callback(items,nil)
                }
            }
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

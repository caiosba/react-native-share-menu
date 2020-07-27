//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by Gustavo Parreira on 26/07/2020.
//

import MobileCoreServices
import UIKit
import Social

extension NSItemProvider {
  var isText: Bool {
    return hasItemConformingToTypeIdentifier(kUTTypeText as String)
  }
  
  var isURL: Bool {
    return hasItemConformingToTypeIdentifier(kUTTypeURL as String)
  }

  var isImage: Bool {
    return hasItemConformingToTypeIdentifier(kUTTypeImage as String)
  }
}

// MARK: Keys

let USER_DEFAULTS_KEY = "ShareMenuUserDefaults"
let HOST_APP_IDENTIFIER_INFO_PLIST_KEY = "HostAppBundleIdentifier"
let HOST_URL_SCHEME_INFO_PLIST_KEY = "HostAppURLScheme"

// MARK: Error Messages

let NO_INFO_PLIST_INDENTIFIER_ERROR = "You haven't defined \(HOST_APP_IDENTIFIER_INFO_PLIST_KEY) in your Share Extension's Info.plist"
let NO_INFO_PLIST_URL_SCHEME_ERROR = "You haven't defined \(HOST_URL_SCHEME_INFO_PLIST_KEY) in your Share Extension's Info.plist"
let COULD_NOT_FIND_STRING_ERROR = "Couldn't find string"
let COULD_NOT_FIND_URL_ERROR = "Couldn't find url"
let COULD_NOT_FIND_IMG_ERROR = "Couldn't find image"
let COULD_NOT_PARSE_IMG_ERROR = "Couldn't parse image"
let COULD_NOT_SAVE_FILE_ERROR = "Couldn't save file on disk"
let NO_APP_GROUP_ERROR = "Failed to get App Group User Defaults. Did you set up an App Group on your App and Share Extension?"

class ShareViewController: SLComposeServiceViewController {
  
  var hostAppId: String?
  var hostAppUrlScheme: String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let hostAppId = Bundle.main.object(forInfoDictionaryKey: HOST_APP_IDENTIFIER_INFO_PLIST_KEY) as? String {
      self.hostAppId = hostAppId
    } else {
      print("Error: \(NO_INFO_PLIST_INDENTIFIER_ERROR)")
    }
    
    if let hostAppUrlScheme = Bundle.main.object(forInfoDictionaryKey: HOST_URL_SCHEME_INFO_PLIST_KEY) as? String {
      self.hostAppUrlScheme = hostAppUrlScheme
    } else {
      print("Error: \(NO_INFO_PLIST_URL_SCHEME_ERROR)")
    }
  }

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
      guard let item = extensionContext?.inputItems.first as? NSExtensionItem else {
        completeRequest()
        return
      }
      guard let provider = item.attachments?.first else {
        completeRequest()
        return
      }
      
      if provider.isText {
        storeText(withProvider: provider)
      } else if provider.isURL {
        storeUrl(withProvider: provider)
      } else if provider.isImage {
        storeImage(withProvider: provider)
      } else {
        completeRequest()
      }
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
  
  func storeText(withProvider provider: NSItemProvider) {
    provider.loadItem(forTypeIdentifier: kUTTypeText as String, options: nil) { (data, error) in
      guard (error == nil) else {
        self.exit(withError: error.debugDescription)
        return
      }
      guard let text = data as? String else {
        self.exit(withError: COULD_NOT_FIND_STRING_ERROR)
        return
      }
      guard let hostAppId = self.hostAppId else {
        self.exit(withError: NO_INFO_PLIST_INDENTIFIER_ERROR)
        return
      }
      guard let userDefaults = UserDefaults(suiteName: "group.\(hostAppId)") else {
        self.exit(withError: NO_APP_GROUP_ERROR)
        return
      }
      
      userDefaults.set(["text": text], forKey: USER_DEFAULTS_KEY)
      userDefaults.synchronize()
      
      self.openHostApp()
    }
  }
  
  func storeUrl(withProvider provider: NSItemProvider) {
    provider.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil) { (data, error) in
      guard (error == nil) else {
        self.exit(withError: error.debugDescription)
        return
      }
      guard let url = data as? URL else {
        self.exit(withError: COULD_NOT_FIND_URL_ERROR)
        return
      }
      guard let hostAppId = self.hostAppId else {
        self.exit(withError: NO_INFO_PLIST_INDENTIFIER_ERROR)
        return
      }
      guard let userDefaults = UserDefaults(suiteName: "group.\(hostAppId)") else {
        self.exit(withError: NO_APP_GROUP_ERROR)
        return
      }
      
      userDefaults.set(["url": url.absoluteString], forKey: USER_DEFAULTS_KEY)
      userDefaults.synchronize()
      
      self.openHostApp()
    }
  }
  
  func storeImage(withProvider provider: NSItemProvider) {
    provider.loadItem(forTypeIdentifier: kUTTypeData as String, options: nil) { (data, error) in
      guard (error == nil) else {
        self.exit(withError: error.debugDescription)
        return
      }
      guard let url = data as? URL else {
        self.exit(withError: COULD_NOT_FIND_IMG_ERROR)
        return
      }
      guard let hostAppId = self.hostAppId else {
        self.exit(withError: NO_INFO_PLIST_INDENTIFIER_ERROR)
        return
      }
      guard let userDefaults = UserDefaults(suiteName: "group.\(hostAppId)") else {
        self.exit(withError: NO_APP_GROUP_ERROR)
        return
      }
      guard let groupFileManagerContainer = FileManager.default
              .containerURL(forSecurityApplicationGroupIdentifier: "group.\(hostAppId)")
      else {
        self.exit(withError: NO_APP_GROUP_ERROR)
        return
      }
      
      let fileExtension = url.pathExtension
      let fileName = UUID().uuidString
      let filePath = groupFileManagerContainer
        .appendingPathComponent("\(fileName).\(fileExtension)")
      
      guard self.moveFileToDisk(from: url, to: filePath) else {
        self.exit(withError: COULD_NOT_SAVE_FILE_ERROR)
        return
      }
      
      userDefaults.set(["image": filePath.absoluteString], forKey: USER_DEFAULTS_KEY)
      userDefaults.synchronize()
      
      self.openHostApp()
    }
  }
  
  private func moveFileToDisk(from srcUrl: URL, to destUrl: URL) -> Bool {
    do {
      if FileManager.default.fileExists(atPath: destUrl.path) {
        try FileManager.default.removeItem(at: destUrl)
      }
      try FileManager.default.copyItem(at: srcUrl, to: destUrl)
    } catch (let error) {
      print("Could not save file from \(srcUrl) to \(destUrl): \(error)")
      return false
    }
    
    return true
  }
  
  private func exit(withError error: String) {
    print("Error: \(error)")
    completeRequest()
  }
  
  private func openHostApp() {
    guard let urlScheme = self.hostAppUrlScheme else {
      exit(withError: NO_INFO_PLIST_URL_SCHEME_ERROR)
      return
    }
    
    let url = URL(string: urlScheme)
    let selectorOpenURL = sel_registerName("openURL:")
    var responder: UIResponder? = self
    
    while responder != nil {
      if responder?.responds(to: selectorOpenURL) == true {
        responder?.perform(selectorOpenURL, with: url)
      }
      responder = responder!.next
    }
    
    completeRequest()
  }
  
  private func completeRequest() {
    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
    extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
  }

}

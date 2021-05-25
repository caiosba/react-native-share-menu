

import UIKit
import MobileCoreServices
import RNShareMenu

extension NSItemProvider {
    var isURL: Bool {
        return hasItemConformingToTypeIdentifier(kUTTypeURL as String)
    }
    var isText: Bool {
        return hasItemConformingToTypeIdentifier(kUTTypeText as String)
    }
    var isImage: Bool {
        return hasItemConformingToTypeIdentifier(kUTTypeImage as String)
    }
}
func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

class ReactShareViewController: UIViewController , RCTBridgeDelegate , ReactShareViewDelegate {
  var moduleRegistryAdapter: UMModuleRegistryAdapter!
  func loadExtensionContext() -> NSExtensionContext {
      return extensionContext!
    }
    
    func openApp() {
   
    }
    
    func continueInApp(with item: NSExtensionItem, and extraData: [String : Any]?) {

    }
  
  static public func requiresMainQueueSetup() -> Bool {
          return false
      }


    func sourceURL(for bridge: RCTBridge!) -> URL! {
  #if DEBUG
      return RCTBundleURLProvider.sharedSettings()?
        .jsBundleURL(forBundleRoot: "index", fallbackResource: nil)
  #else
      return Bundle.main.url(forResource: "main", withExtension: "jsbundle")
  #endif
    }
  
    override func viewDidLoad() {
      super.viewDidLoad()
     
      let bridge: RCTBridge! = RCTBridge(delegate: self, launchOptions: nil)
      let rootView = RCTRootView(
        bridge: bridge,
        moduleName: "ShareMenuModuleComponent",
        initialProperties: nil
      )
      rootView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
          self.view = rootView
      self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height + 100.0)
      ShareMenuReactView.attachViewDelegate(self)
    }
  func extraModules(for bridge: RCTBridge!) -> [RCTBridgeModule]! {
      if(self.moduleRegistryAdapter == nil) {
        self.moduleRegistryAdapter = UMModuleRegistryAdapter(moduleRegistryProvider: UMModuleRegistryProvider())
      }
      let extraModules = self.moduleRegistryAdapter.extraModules(for: bridge)
      return extraModules
    }
}

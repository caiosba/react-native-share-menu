// MARK: Error Messages

let NO_URL_TYPES_ERROR_MESSAGE = "You have not defined CFBundleURLTypes in your Info.plist"
let NO_URL_SCHEMES_ERROR_MESSAGE = "You have not defined CFBundleURLSchemes in your Info.plist"
let NO_SCHEME_ERROR_MESSAGE = "You have not defined a scheme under CFBundleURLSchemes in your Info.plist"
let NO_APP_GROUP_ERROR = "Failed to get App Group User Defaults. Did you set up an App Group on your App and Share Extension?"

// MARK: Keys

let USER_DEFAULTS_KEY = "ShareMenuUserDefaults"
let URL_SCHEME_INFO_PLIST_KEY = "AppURLScheme"

@objc(ShareMenu)
open class ShareMenu: NSObject {
    
    private static var sharedData: [String:Any]?
    
    private static var _targetUrlScheme: String?
    private static var targetUrlScheme: String
    {
        get {
            return ShareMenu._targetUrlScheme!
        }
    }
    
    @objc static public func requiresMainQueueSetup() -> Bool {
        return true
    }
    
    @objc static public func share(
        application app: UIApplication,
        openUrl url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any]
    ) {
        if _targetUrlScheme == nil {
            guard let bundleUrlTypes = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [NSDictionary] else {
                print("Error: \(NO_URL_TYPES_ERROR_MESSAGE)")
                return
            }
            guard let bundleUrlSchemes = bundleUrlTypes.first?.value(forKey: "CFBundleURLSchemes") as? [String] else {
                print("Error: \(NO_URL_SCHEMES_ERROR_MESSAGE)")
                return
            }
            guard let expectedUrlScheme = bundleUrlSchemes.first else {
                print("Error \(NO_URL_SCHEMES_ERROR_MESSAGE)")
                return
            }
            
            _targetUrlScheme = expectedUrlScheme
        }
        guard let scheme = url.scheme, scheme == targetUrlScheme else { return }
        guard let bundleId = Bundle.main.bundleIdentifier else { return }
        guard let userDefaults = UserDefaults(suiteName: "group.\(bundleId)") else {
            print("Error: \(NO_APP_GROUP_ERROR)")
            return
        }
        
        if let data = userDefaults.object(forKey: USER_DEFAULTS_KEY) as? [String:Any] {
            sharedData = data
        }
    }
    
    @objc(getSharedText:)
    func getSharedText(callback: RCTResponseSenderBlock) {
        let sharedData = ShareMenu.sharedData
        
        if let (_, data) = sharedData?.first {
            callback([data as! String])
            ShareMenu.sharedData = nil
            return
        }
        
        callback([""])
    }
}

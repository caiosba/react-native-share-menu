// MARK: Error Messages

let NO_URL_TYPES_ERROR_MESSAGE = "You have not defined CFBundleURLTypes in your Info.plist"
let NO_URL_SCHEMES_ERROR_MESSAGE = "You have not defined CFBundleURLSchemes in your Info.plist"
let NO_SCHEME_ERROR_MESSAGE = "You have not defined a scheme under CFBundleURLSchemes in your Info.plist"
let NO_APP_GROUP_ERROR = "Failed to get App Group User Defaults. Did you set up an App Group on your App and Share Extension?"

// MARK: Keys

let USER_DEFAULTS_KEY = "ShareMenuUserDefaults"
let URL_SCHEME_INFO_PLIST_KEY = "AppURLScheme"

// MARK: Events

let NEW_SHARE_EVENT = "NewShareEvent"

@objc(ShareMenu)
class ShareMenu: RCTEventEmitter {

    private(set) static var _shared: ShareMenu?
    @objc public static var shared: ShareMenu
    {
        get {
            return ShareMenu._shared!
        }
    }

    var sharedData: [String:Any]?

    static var initialShare: (UIApplication, URL, [UIApplication.OpenURLOptionsKey : Any])?

    var hasListeners = false

    var _targetUrlScheme: String?
    var targetUrlScheme: String
    {
        get {
            return _targetUrlScheme!
        }
    }

    public override init() {
        super.init()
        ShareMenu._shared = self

        if let (app, url, options) = ShareMenu.initialShare {
            share(application: app, openUrl: url, options: options)
        }
    }

    override static public func requiresMainQueueSetup() -> Bool {
        return true
    }

    open override func supportedEvents() -> [String]! {
        return [NEW_SHARE_EVENT]
    }

    open override func startObserving() {
        hasListeners = true
    }

    open override func stopObserving() {
        hasListeners = false
    }

    public static func messageShare(
        application app: UIApplication,
        openUrl url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any]
    ) {
        guard (ShareMenu._shared != nil) else {
            initialShare = (app, url, options)
            return
        }
        
        ShareMenu.shared.share(application: app, openUrl: url, options: options)
    }
    
    func share(
        application app: UIApplication,
        openUrl url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any]) {
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
            dispatchEvent(with: data)
            userDefaults.removeObject(forKey: USER_DEFAULTS_KEY)
        }
    }

    @objc(getSharedText:)
    func getSharedText(callback: RCTResponseSenderBlock) {
        callback([extractShare(from: sharedData)])
        sharedData = nil
    }
    
    func dispatchEvent(with data: [String:Any]) {
        guard hasListeners else { return }
        
        let share = extractShare(from: data)
        sendEvent(withName: NEW_SHARE_EVENT, body: share)
    }
    
    func extractShare(from data: [String:Any]?) -> String {
        guard let (_, share) = data?.first else {
            return ""
        }
        return share as! String
    }
}

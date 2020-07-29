require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "RNShareMenu"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platforms    = { :ios => "9.0" }
  s.source       = { :git => "https://github.com/meedan/react-native-share-menu.git", :tag => "#{s.version}" }
  s.swift_version = "5.2"


  s.source_files = "ios/**/*.{h,m,mm,swift}"
  s.exclude_files = [
    "ios/ShareViewController.swift",
    "ios/ReactShareViewController.swift"
  ]


  s.dependency "React"
end

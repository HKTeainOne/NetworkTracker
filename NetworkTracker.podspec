Pod::Spec.new do |s|
  s.name         = "NetworkTracker"
  s.version      = "0.0.1"
  s.summary      = "NetworkTracker"
  s.homepage     = "https://github.com/xzj324/NetworkTracker"
  s.license      = "MIT"
  s.authors      = { "xzj" => "xzj3024@163.com" }
  s.source       = { :git => "https://github.com/xzj324/NetworkTracker.git", :tag => s.version }
  s.frameworks   = 'Foundation', 'UIKit'
  s.ios.deployment_target = '7.0'
  s.source_files = 'NetworkTracker/NetworkTracker/**/*.{h,m,png}'
  s.requires_arc = true
end
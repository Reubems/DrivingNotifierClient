platform :ios, '11.0'
use_frameworks!
inhibit_all_warnings!

target 'DrivingNotifier' do
  pod 'OneSignal', '>= 2.5.2', '< 3.0'
  pod 'SnapKit', '4.0.0'
  pod 'SwiftLint'
  pod 'CryptoSwift'
  pod 'CocoaLumberjack/Swift', '~> 3.0.0'
  pod 'HumioCocoaLumberjackLogger', :git => "https://github.com/jjuncker/HumioCocoaLumberjackLogger.git"
  pod 'ThePerfectApp', '4.6.2'
end

target 'OneSignalNotificationServiceExtension' do
  pod 'OneSignal', '>= 2.5.2', '< 3.0'
  pod 'SnapKit', '4.0.0'
end


post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
            config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
            config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
        end
    end
end

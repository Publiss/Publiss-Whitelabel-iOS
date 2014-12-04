#
#  Be sure to run `pod spec lint Publiss.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name                      = 'Publiss'
  s.version                   = '2.0.4'
  s.summary                   = 'Publiss enables you to enrich PDFs with multimedia content and publish them to a high-quality iPhone and iPad App - all by yourself.'
  s.homepage                  = 'http://www.publiss.com'
  s.screenshots               = 'https://github.com/Publiss/Publiss-Whitelabel-iOS/raw/master/iPhone_iPad_Kiosk.png'
  s.license                   = 'MIT'
  s.author                    = 'Publiss GmbH'
  s.platform                  = :ios, '7.1'
  s.source                    = { :git => 'https://github.com/Publiss/Publiss-Whitelabel-iOS.git', :tag => '2.0.4'}
  s.source_files              = 'Publiss/3rd Party/*.{h,m}', 'Publiss/PSPDFSubclasses/*.{h,m}', 'Publiss/Classes/*.{h,m}', 'Publiss/PUBVersion.h', 'PublissCore.embeddedframework/**/*.h'

  s.resources                 = ['Publiss/Images.xcassets', 'Publiss/Views/*.*', 'Publiss/*.{xcdatamodeld,xcdatamodel}', 'Publiss/Publiss.bundle']

  s.preserve_paths            = 'PublissCore.embeddedframework', 'Publiss/Publiss.xcdatamodeld'
  s.framework                 = 'CoreData'
  s.vendored_frameworks       = 'PublissCore.embeddedframework/PublissCore.framework'
  s.prefix_header_contents    = '#import <CoreData/CoreData.h>', '#import 'Publiss.h''
  s.requires_arc              = true
  s.xcconfig                  = { 'FRAMEWORK_SEARCH_PATHS' => '"$(PODS_ROOT)/Publiss/PublissCore.embeddedframework"' }

  s.dependency 'PSPDFKit', '4.1.2'
  s.dependency 'AFNetworking', '2.4.1'
  s.dependency 'Lockbox', '2.1.0'
  s.dependency 'REFrostedViewController', '2.4.7'
  s.dependency 'JDStatusBarNotification', '1.4.9'
  s.dependency 'UIActionSheet+Blocks', '0.8.1'
  s.dependency 'GoogleAnalytics-iOS-SDK', '3.10'

end

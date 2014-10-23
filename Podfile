source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '7.1'
pod 'AFNetworking', '~> 2.4.1'
pod 'Lockbox', '~> 1.4'
pod 'PSPDFKit' '~> 4.0.3'
pod 'JDStatusBarNotification'
pod 'GoogleAnalytics-iOS-SDK', '~> 3.0'
pod 'UIActionSheet+Blocks'
pod 'REFrostedViewController'

post_install do |installer|
	puts "CREATING VERSION FILE"
	File.open("Publiss/PUBVersion.h", 'w+') {|f| f.write('#define PUB_GIT_VERSION @""'+"\n") }
end

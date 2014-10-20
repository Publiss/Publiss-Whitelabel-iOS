platform :ios, '7.1'            
pod 'AFNetworking', '~> 2.3'
pod 'Lockbox', '~> 1.4'
pod 'PSPDFKit'
pod 'REMenu', '~> 1.9'
pod 'JDStatusBarNotification'
pod 'GoogleAnalytics-iOS-SDK', '~> 3.0'
pod 'UIActionSheet+Blocks'

post_install do |installer|
	puts "CREATING VERSION FILE"
	File.open("Publiss/PUBVersion.h", 'w+') {|f| f.write('#define PUB_GIT_VERSION @""'+"\n") }
end

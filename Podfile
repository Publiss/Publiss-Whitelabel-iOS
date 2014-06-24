platform :ios, '7.1'            
pod 'AFNetworking', '2.2.3'     
pod 'Lockbox', '~> 1.4.6'
pod 'PSPDFKit', '~> 3.7.5'
pod 'REMenu', '~> 1.8.4'
pod 'JDStatusBarNotification', '~> 1.4.7'

post_install do |installer|
	puts "CREATING VERSION FILE"
	File.open("Publiss/PUBVersion.h", 'w+') {|f| f.write('#define PUB_GIT_VERSION @""'+"\n") }
end

#
#  Be sure to run `pod spec lint Publiss.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "Publiss"
  s.version      = "1.14"
  s.summary      = "Publiss enables you to enrich PDFs with multimedia content and publish them to a high-quality iPhone and iPad App - all by yourself."

  s.description  = <<-DESC
                   A longer description of Publiss in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC

  s.homepage     = "http://www.publiss.com"
  s.screenshots  = "https://github.com/Publiss/Publiss-Whitelabel-iOS/raw/master/iPhone_iPad_Kiosk.png"
  s.license      = "MIT"
  
  s.author       = "Publiss GmbH"
  
  s.platform     = :ios, "7.1"

  s.source       = { :git => "git@bitbucket.org:bytepoets-dgr/publiss-pod-test.git" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any h, m, mm, c & cpp files. For header
  #  files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #

  s.source_files  = "Publiss/3rd Party/*.{h,m}", "Publiss/PSPDFSubclasses/*.{h,m}", "Publiss/Classes/*.{h,m}", "Publiss/PUBVersion.h", "PublissCore.embeddedframework/**/*.h"
  # s.exclude_files = "Classes/Exclude"

  # s.public_header_files = 


  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  # s.resource  = "icon.png"
  s.resources = ["Publiss/Images.xcassets/**/*.png", "Publiss/Views/*.*", "Publiss/*.{xcdatamodeld,xcdatamodel}"]
  s.preserve_paths = "PublissCore.embeddedframework", "Publiss/Publiss.xcdatamodeld"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  s.framework  = "PublissCore", "CoreData"
  s.prefix_header_contents = '#import <CoreData/CoreData.h>'
  # s.frameworks = "SomeFramework", "AnotherFramework"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  s.xcconfig     = { 'FRAMEWORK_SEARCH_PATHS' => '"$(PODS_ROOT)/PublissCore.embeddedframework"' }
  s.dependency "PSPDFKit"
  s.dependency "AFNetworking"
  s.dependency "Lockbox"
  s.dependency "REMenu"
  s.dependency "JDStatusBarNotification"
  s.dependency "GoogleAnalytics-iOS-SDK"

end

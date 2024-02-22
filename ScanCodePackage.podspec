#
#  Be sure to run `pod spec lint PullDownListSwift.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  spec.name         = "ScanCodePackage"
  spec.version      = "1.0.0"
  spec.swift_version  = "5.0"
  spec.summary      = "ScanCodePackage 扫码、扫描二维码/条形码功能，自定义扫码界面视图，生成二维码/条形码"
  spec.description  = <<-DESC
                            ScanCodePackage 是一个扫描二维码和条形码功能，自定义各种样式扫码视图，生成二维码和条形码等功能的封装
                        DESC
  spec.homepage     = "https://github.com/CMlinksuccess/ScanCodePackage"
  spec.license      = 'MIT'
  spec.author       = { "xiaowanjia" => "myemil0@163.com" }
  spec.source       = { :git => "https://github.com/CMlinksuccess/ScanCodePackage.git", :tag => "#{spec.version}" }
  spec.platform     = :ios, '13.0'
  spec.requires_arc = true
  
  spec.resource  = 'ScanCodePackage/ScanCodePackage/scanResource.bundle'
  spec.source_files  = 'ScanCodePackage/ScanCodePackage/*.{swift,bundle}'
  spec.frameworks = 'UIKit'
  
end

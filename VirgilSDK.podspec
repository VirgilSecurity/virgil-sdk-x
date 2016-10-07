Pod::Spec.new do |s|
  s.name                  = "VirgilSDK"
  s.version               = "4.0.0-alpha5"
  s.summary               = "Virgil SDK for Apple devices and languages."
  s.cocoapods_version     = ">= 0.36"
  s.homepage              = "https://github.com/VirgilSecurity/virgil-sdk-x/tree/v4"
  s.license               = { :type => "BSD", :file => "LICENSE" }
  s.author                = { "Oleksandr Deundiak" => "deundiak@gmail.com" }
  s.platforms             = { :ios => "7.0" }
  s.source                = { :git => "https://github.com/VirgilSecurity/virgil-sdk-x.git", :tag => s.version }
  s.module_name           = "VirgilSDK"
  s.source_files          = "Classes/**/*"
  # s.public_header_files   = "Classes/VirgilSDK.h"
  s.private_header_files  = "Classes/Utils/*.{h}"
  s.requires_arc          = true
  s.dependency "VirgilCrypto", "~> 2.0.0-beta9"
end
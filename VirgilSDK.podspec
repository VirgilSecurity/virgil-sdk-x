Pod::Spec.new do |s|
  s.name                  = "VirgilSDK"
  s.version               = "4.0.0-alpha1"
  s.summary               = "Virgil SDK for Apple devices and languages."
  s.cocoapods_version     = ">= 0.36"
  s.homepage              = "https://github.com/VirgilSecurity/virgil-sdk-x/tree/v4"
  s.license               = { :type => "BSD", :file => "LICENSE" }
  s.author                = { "Pavlo Gorb" => "virgil.orbitum@gmail.com" }
  s.platforms             = { :ios => "9.0" }
  s.source                = { :git => "https://github.com/VirgilSecurity/virgil-sdk-x.git", :tag => s.version }  
  s.module_name           = "VirgilSDK"
  s.source_files          = "Classes/**/*"
  s.private_header_files  = "Classes/Networking/Requests/Identity/**/*.h", "Classes/Networking/Requests/Keys/**/*.h", "Classes/Networking/Requests/PrivateKeys/**/*.h"
  s.requires_arc          = true
  s.dependency "VirgilFoundation", "~> 1.8"
end
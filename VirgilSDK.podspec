Pod::Spec.new do |s|
  s.name                  = "VirgilSDK"
  s.version               = "0.9.0"
  s.summary               = "Virgil SDK for Apple devices and languages."
  s.cocoapods_version     = ">= 0.36"
  s.homepage              = "https://github.com/VirgilSecurity/virgil-sdk-keys-x"
  s.license               = { :type => "BSD", :file => "LICENSE" }
  s.author                = { "Pavlo Gorb" => "virgil.orbitum@gmail.com" }
  s.platforms             = { :osx => "10.11", :ios => "8.0", :watchos => "2.0", :tvos => "9.0" }
  s.source                = { :path => "/Users/Orbitum/Projects/VirgilPods/virgil-sdk-keys-x" }  
  s.module_name           = "VirgilSDK"
  s.source_files          = "Classes/**/*"
  s.private_header_files  = "Classes/Networking/Requests/Identity/**/*.h", "Classes/Networking/Requests/Keys/**/*.h", "Classes/Networking/Requests/PrivateKeys/**/*.h"
  s.requires_arc          = true
  s.dependency "VirgilFoundation"
end
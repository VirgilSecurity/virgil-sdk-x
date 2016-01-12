Pod::Spec.new do |s|
  s.name                  = "VirgilKeys"
  s.version               = "2.2.1"
  s.summary               = "VirgilKeys offers SDK for Virgil Keys service calls and models."
  s.homepage              = "https://github.com/VirgilSecurity/virgil-sdk-keys-x"
  s.license               = { :type => "BSD", :file => "LICENSE" }
  s.author                = { "Pavlo Gorb" => "p.orbitum@gmail.com" }
  s.platforms               = { :osx => "10.11", :ios => "8.0", :watchos => "2.0", :tvos => "9.0" }
  s.source                = { :git => "https://github.com/VirgilSecurity/virgil-sdk-keys-x.git", :tag => "2.2.1" }
  s.source_files          = "Classes/**/*"
  s.public_header_files   = "Classes/**/*.h"
  s.requires_arc          = true
  s.dependency "VirgilFoundation"
  s.dependency "VirgilKit"
end
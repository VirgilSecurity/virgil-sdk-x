Pod::Spec.new do |s|
  s.name                    = "VirgilKeysiOS"
  s.version                 = "2.2.0"
  s.summary                 = "VirgilKeysiOS offers SDK for Virgil Keys service calls and models."
  s.homepage                = "https://github.com/VirgilSecurity/VirgilKeysiOS"
  s.license                 = { :type => "BSD", :file => "LICENSE" }
  s.author                  = { "Pavlo Gorb" => "p.orbitum@gmail.com" }
  s.platform                = :ios, "8.0"
  s.source                  = { :git => "https://github.com/VirgilSecurity/VirgilKeysiOS.git", :tag => "2.2.0" }
  s.source_files            = "Classes/**/*"
  s.public_header_files     = "Classes/**/*.h"
  s.requires_arc            = true
  s.deprecated              = true
  s.deprecated_in_favor_of  = 'VirgilKeys'
  s.dependency "VirgilFoundation"
  s.dependency "VirgilKit"  
end
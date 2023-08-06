Pod::Spec.new do |s|
  s.name                        = "VirgilSDK"
  s.version                     = "8.2.1-rc.2"
  s.swift_version               = "5.0"
  s.license                     = { :type => "BSD", :file => "LICENSE" }
  s.summary                     = "Virgil SDK for Apple devices and languages."
  s.homepage                    = "https://github.com/VirgilSecurity/virgil-sdk-x/"
  s.authors                     = { "Virgil Security" => "https://virgilsecurity.com/" }
  s.source                      = { :git => "https://github.com/VirgilSecurity/virgil-sdk-x.git", :tag => s.version }
  s.ios.deployment_target       = "11.0"
  s.osx.deployment_target       = "10.13"
  s.tvos.deployment_target      = "11.0"
  s.watchos.deployment_target   = "4.0"
  s.source_files                = 'Source/**/*.{h,m,swift}'
  s.public_header_files         = 'Source/VirgilSDK.h',
                                  'Source/KeychainStorage/*.h'
  s.dependency "VirgilCrypto", "= 6.1.0"
end

Pod::Spec.new do |s|
  s.name                  = "VirgilSDK"
  s.version               = "4.4.0"
  s.summary               = "Virgil SDK for Apple devices and languages."
  s.cocoapods_version     = ">= 0.36"
  s.homepage              = "https://github.com/VirgilSecurity/virgil-sdk-x/"
  s.license               = { :type => "BSD", :file => "LICENSE" }
  s.author                = { "Oleksandr Deundiak" => "deundiak@gmail.com" }
  s.platforms             = { :ios => "7.0", :osx => "10.10" }
  s.source                = { :git => "https://github.com/VirgilSecurity/virgil-sdk-x.git",
                              :tag => s.version }
  s.weak_frameworks       = 'Foundation'
  s.module_name           = 'VirgilSDK'
  s.source_files          = 'Source/**/*.{h,m}'
  s.public_header_files   = 'Source/*.{h}',
                            'Source/Client/*.{h}',
                            'Source/Client/Models/*.{h}',
                            'Source/Client/Models/Requests/*.{h}',
                            'Source/Client/Models/Responses/*.{h}',
                            'Source/Client/Models/SnapshotModels/*.{h}',
                            'Source/Client/Models/Protocols/*.{h}',
                            'Source/Crypto/*.{h}',
                            'Source/Crypto/Keys/*.{h}',
                            'Source/DeviceManager/**/*.{h}',
                            'Source/KeyStorage/**/*.{h}',
                            'Source/HighLevel/*.{h}'
  s.ios.exclude_files     = "Source/**/macOS/*.{h,m}"
  s.osx.exclude_files     = "Source/**/iOS/*.{h,m}"
  s.requires_arc          = true
  s.dependency "VirgilCrypto", "~> 2.1"
end
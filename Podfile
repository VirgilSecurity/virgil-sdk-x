source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

target 'VirgilSDK iOS' do
	pod 'VirgilCrypto', '~> 2.0.4'

    target 'VirgilSDKTests' do
        inherit! :search_paths
    end

    target 'VirgilSDKSwiftTests' do
        inherit! :search_paths
    end
end

target 'TestSDKApp' do
	pod 'VirgilSDK', :path => './'
end
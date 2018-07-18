gem install jazzy

jazzy \
--author "Virgil Security" \
--author_url "https://virgilsecurity.com/" \
--xcodebuild-arguments -scheme,"VirgilSDK macOS" \
--module "VirgilSDK" \
--output "docs" \
--hide-documentation-coverage \
--theme apple
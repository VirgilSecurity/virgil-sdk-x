brew update;
brew outdated carthage || brew upgrade carthage;
carthage build --use-xcframeworks --no-skip-current;

# TODO: Should be replaced by carthage archive, when it supports xcframeworks
FRAMEWORKS_PATH=Carthage/Build
find ${FRAMEWORKS_PATH} -mindepth 1 -maxdepth 1 ! -name 'VirgilSDK.xcframework' -exec rm -rvf {} \;
zip -r VirgilSDK.xcframework.zip ${FRAMEWORKS_PATH}

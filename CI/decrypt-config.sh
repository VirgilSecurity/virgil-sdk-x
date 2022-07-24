openssl aes-256-cbc -K $ENCRYPTION_KEY -iv $ENCRYPTION_IV -in config.tar.enc -out config.tar -d
tar xvf config.tar
mv TestConfig.plist Tests/Swift/Data/TestConfig.plist
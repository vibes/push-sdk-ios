
#!/bin/sh

xcodebuild archive \
-scheme VibesPush-iOS \
-destination "generic/platform=iOS Simulator" \
-archivePath ../output/VibesPush-sim \
SKIP_INSTALL=NO \
BUILD_LIBRARY_FOR_DISTRIBUTION=YES

xcodebuild archive \
-scheme VibesPush-iOS \
-destination "generic/platform=iOS" \
-archivePath ../output/VibesPush \
SKIP_INSTALL=NO \
BUILD_LIBRARY_FOR_DISTRIBUTION=YES

xcodebuild -create-xcframework \
-framework ../output/VibesPush.xcarchive/Products/Library/Frameworks/VibesPush.framework \
-framework ../output/VibesPush-sim.xcarchive/Products/Library/Frameworks/VibesPush.framework \
-output ../output/VibesPush.xcframework


#!/bin/sh

rm -fr /tmp/Vibes*

xcodebuild -workspace "VibesPush.xcworkspace" -scheme "VibesPush-iOS" ONLY_ACTIVE_ARCH=NO -configuration "Release" -arch arm64 -arch armv7 -arch armv7s ENABLE_BITCODE=YES OTHER_CFLAGS="-fembed-bitcode" -sdk iphoneos clean build


xcodebuild -workspace "VibesPush.xcworkspace" -scheme "VibesPush-iOS" ONLY_ACTIVE_ARCH=NO -configuration "Release" -arch x86_64 -arch i386 ENABLE_BITCODE=YES OTHER_CFLAGS="-fembed-bitcode-marker" -sdk iphonesimulator clean build


cp -R "/Users/jean-michel.barbieri/Library/Developer/Xcode/DerivedData/VibesPush-emvuczciplwqpnatcooaelocrhiq/Index/DataStore/../../Build/Products/Release-iphoneos/VibesPush.framework" /tmp


cp -R "/Users/jean-michel.barbieri/Library/Developer/Xcode/DerivedData/VibesPush-emvuczciplwqpnatcooaelocrhiq/Index/DataStore/../../Build/Products/Release-iphonesimulator/VibesPush.framework/Modules/VibesPush.swiftmodule" "/tmp/VibesPush.framework/Modules"


lipo -create -output "/tmp/VibesPush.framework/VibesPush" "/Users/jean-michel.barbieri/Library/Developer/Xcode/DerivedData/VibesPush-emvuczciplwqpnatcooaelocrhiq/Index/DataStore/../../Build/Products/Release-iphonesimulator/VibesPush.framework/VibesPush" "/tmp/VibesPush.framework/VibesPush"

cd /tmp/

zip -r -X VibesPush.zip VibesPush.framework/

mv /tmp/VibesPush.zip /Users/jean-michel.barbieri/Developer/SDK/iOS/vibes-sdk-ios/VibesPush/Frameworks/iOS/



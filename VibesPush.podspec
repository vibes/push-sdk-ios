Pod::Spec.new do |s|  
    s.name              = 'VibesPush'
    s.version           = '4.8.3'
    s.summary           = 'iOS SDK for Vibes push messaging'
    s.homepage          = 'http://www.vibes.com'

    s.author            = { 'Vibes' => 'jean-michel.barbieri@vibes.com' }
    s.license           = { :type => 'Apache-2.0', :file => 'LICENSE' }

    s.platform          = :ios
    s.swift_version     = '5.0'
    s.source            = { :git => 'https://github.com/vibes/push-sdk-ios.git', :tag => s.version.to_s }
    s.platforms		    = { :ios => "15.6" }
    s.requires_arc	    = true
    s.default_subspec	= "Core"
    s.subspec "Core" do |ss|
       ss.source_files  = "Sources/**/*.swift"
        ss.framework    = "Foundation"
    end
end 


Pod::Spec.new do |s|  
    s.name              = 'VibesPush'
    s.version           = '1.0.0'
    s.summary           = 'SDK for Vibes push messaging'
    s.homepage          = 'http://www.vibes.com'

    s.author            = { 'Vibes' => 'jean-michel.barbieri@vibes.com' }
    s.license           = { :type => 'Apache-2.0', :file => 'LICENSE' }

    s.platform          = :ios
    s.source            = { :git => 'git@git.vibes.com:push/vibes-sdk-ios.git', :tag => s.version.to_s }
    s.platforms		= { :ios => "8.0", :osx => "10.10", :tvos => "9.0", :watchos => "2.0" }
    s.requires_arc	= true
    s.default_subspec	= "Core"
    s.subspec "Core" do |ss|
       ss.source_files  = "Sources/**/*.swift"
        ss.framework  = "Foundation"
    end
end 


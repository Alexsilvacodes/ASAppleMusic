Pod::Spec.new do |s|
  s.name             = 'ASAppleMusic'
  s.version          = '1.1.7'
  s.summary          = 'Apple Music library for developer and user token.'
  s.description      = <<-DESC
ASAppleMusic is a framework created to help developers to use the Apple Music API with their developer token or the user token that will be requested to the device user
                       DESC

  s.homepage         = 'https://github.com/Alexsays/ASAppleMusic'
  s.license          = { :type => 'CC BY-SA 4.0', :file => 'LICENSE' }
  s.author           = { 'Alex Silva' => 'alex@alexsays.info' }
  s.source           = { :git => 'https://github.com/Alexsays/ASAppleMusic.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/alexw0h4l'
  s.documentation_url = 'http://asapplemusic.alexsays.info'
  s.ios.deployment_target = '11.0'
  s.source_files = 'ASAppleMusic/Classes/**/*'
  s.ios.framework  = 'UIKit'
  s.dependency 'Alamofire'
  s.dependency 'EVReflection/Alamofire'
end

#
# Be sure to run `pod lib lint NetworkSpeedTest.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NetworkSpeedTest'
  s.version          = '0.1.1'
  s.summary          = 'Passively collecting network statistics for iOS'
  s.homepage         = 'https://github.com/ml-works/NetworkSpeedTest'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Vladislav Dugnist' => 'vdugnist@gmail.com' }
  s.source           = { :git => 'https://github.com/ml-works/NetworkSpeedTest.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/vdugnist'

  s.ios.deployment_target = '8.0'

  s.source_files = 'SpeedTestExample/SpeedTest/*'
end

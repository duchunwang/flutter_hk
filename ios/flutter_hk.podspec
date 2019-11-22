#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flutter_hk'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'

  s.ios.deployment_target = '8.0'
  
  # s.vendored_libraries = 'lib/*.a'
  # s.libraries = 'c++'
  s.vendored_libraries = 'lib/Release-iphoneos/*.a'
  s.frameworks = 'AudioToolbox', 'VideoToolbox', 'GLKit'
  s.libraries = 'bz2', 'iconv', 'c++'
  # s.ios.vendored_frameworks = 'Frameworks/frameworktest.framework'
  # s.vendored_frameworks = 'frameworktest.framework'
end


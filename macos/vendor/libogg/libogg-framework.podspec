# libogg 1.3.6 (arm64) as a framework, so FLAC.framework does not depend on a homebrew install.
Pod::Spec.new do |s|
  s.name         = 'libogg-framework'
  s.version      = '1.3.6'
  s.summary      = 'libogg as a macOS framework'
  s.homepage     = 'https://xiph.org/ogg'
  s.license      = { :type => 'BSD', :file => 'LICENSE' }
  s.author       = 'Xiph.Org Foundation'
  s.source       = { :path => '.' }
  s.platform     = :osx, '13.0'
  s.vendored_frameworks = 'Ogg.framework'
end

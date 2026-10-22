# Vendored copy of arthenica/ffmpeg-kit v6.0 (audio, macOS): upstream removed its release binaries.
Pod::Spec.new do |s|
  s.name         = 'ffmpeg-kit-macos-audio'
  s.version      = '6.0'
  s.summary      = 'FFmpeg Kit macOS Audio Shared Framework'
  s.homepage     = 'https://github.com/arthenica/ffmpeg-kit'
  s.license      = { :type => 'LGPL-3.0', :file => 'LICENSE' }
  s.author       = { 'ARTHENICA' => 'open-source@arthenica.com' }
  s.source       = { :path => '.' }
  s.platform     = :osx, '10.15'
  s.requires_arc = true
  s.libraries    = 'z', 'bz2', 'c++', 'iconv'
  s.osx.frameworks = 'AudioToolbox', 'AVFoundation', 'CoreAudio', 'CoreImage', 'CoreMedia', 'OpenCL', 'OpenGL', 'VideoToolbox'
  s.osx.vendored_frameworks = 'ffmpegkit.xcframework', 'libavcodec.xcframework', 'libavdevice.xcframework',
    'libavfilter.xcframework', 'libavformat.xcframework', 'libavutil.xcframework',
    'libswresample.xcframework', 'libswscale.xcframework'
end

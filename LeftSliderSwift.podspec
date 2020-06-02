Pod::Spec.new do |spec|

  spec.name         = "LeftSliderSwift"
  spec.version      = "0.0.3"
  spec.summary      = "Easy left slider menu manger write by swift."

  spec.description  = <<-DESC
  Easy left slider menu manger write by swift. have fun!
                   DESC

  spec.homepage     = "https://github.com/jiuyuehuiyi/LeftSliderDemo"


  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "踏歌长行" => "1031484446@qq.com" }

  spec.platform     = :ios, "9.0"
  spec.ios.deployment_target = '9.0'
  spec.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.0' }
  spec.requires_arc = true
  
  spec.source       = { :git => "https://github.com/jiuyuehuiyi/LeftSliderDemo.git", :tag => "#{spec.version}" }
  spec.source_files  = "TestLeftSliderDemoForSwift/TestLeftSliderDemoForSwift/LeftSliderManager"


end

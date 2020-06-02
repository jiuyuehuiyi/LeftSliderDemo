Pod::Spec.new do |spec|

  spec.name         = "LeftSlider"
  spec.version      = "0.0.1"
  spec.summary      = "Easy left slider menu manger write by oc."

  spec.description  = <<-DESC
  Easy left slider menu manger write by oc. have fun!
                   DESC

  spec.homepage     = "https://github.com/jiuyuehuiyi/LeftSliderDemo"


  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "踏歌长行" => "1031484446@qq.com" }

  spec.platform     = :ios, "9.0"
  spec.ios.deployment_target = '9.0'
  spec.requires_arc = true
  
  spec.source       = { :git => "https://github.com/jiuyuehuiyi/LeftSliderDemo.git", :tag => "#{spec.version}" }
  spec.source_files  = "TestLeftSliderDemoForOC/LeftSliderManager"


end

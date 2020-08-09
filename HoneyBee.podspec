
Pod::Spec.new do |s|
  s.name         = "HoneyBee"
  s.version      = "3.0.0.1"
  s.summary      = "A swift futures library to increase the expressiveness of asynchronous and concurrent programming."

  s.homepage     = "http://HoneyBee.link/2.8.2/docs/index.html"
	s.documentation_url = s.homepage

  s.license      = { :type=>"MIT" }

  s.author       = { "Alex Lynch" => "alex@iamapps.net" }

  s.ios.deployment_target = "10.0"
  s.osx.deployment_target = "10.11"
  s.tvos.deployment_target = "10.0"
  s.pod_target_xcconfig = { "SWIFT_VERSION" => "5.2" }

  s.source       = { :git => "https://github.com/lynchsft/HoneyBee.git", :tag=>"v3.0.0.a1"}

  s.source_files = "HoneyBee/*.swift"
end	

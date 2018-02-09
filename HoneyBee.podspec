
Pod::Spec.new do |s|
  s.name         = "HoneyBee"
  s.version      = "2.3.1"
  s.summary      = "A swift library to increase the expressiveness of asynchronous and concurrent programming."

  s.homepage     = "http://HoneyBee.link/2.3.1/docs/index.html"
	s.documentation_url = s.homepage

  s.license      = { :type=>"MIT" }

  s.author       = { "Alex Lynch" => "alex@iamapps.net" }

  s.ios.deployment_target = "10.0"
  s.osx.deployment_target = "10.11"
  s.tvos.deployment_target = "10.0"
  s.pod_target_xcconfig = { "SWIFT_VERSION" => "4.0" }

  s.source       = { :git => "https://bitbucket.org/iam_apps/honeybee.git", :tag=>"v2.3.1"}

  s.source_files = "HoneyBee/*.swift"
end	

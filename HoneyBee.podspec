
Pod::Spec.new do |s|
  s.name         = "HoneyBee"
  s.version      = "1.11.0"
  s.summary      = "A swift library to increase the expressiveness of asynchronous and concurrent programming."

  s.description  = <<-DESC
	HoneyBee reduces the clutter and complexity of asynchronous and concurrent code. 
	By handing the noise of data routing and error handling, HoneyBee provides a higher-level, more expressive perspective on asynchronous programming.
                   DESC

  s.homepage     = "http://iamapps.net/HoneyBee/1.11.0/docs/index.html"
	s.documentation_url = s.homepage

  s.license      = { :type=>"MIT", :file => 'LICENSE' }

  s.author       = { "Alex Lynch" => "alex@iamapps.com" }

  s.ios.deployment_target = "10.0"
  s.osx.deployment_target = "10.10"
  s.watchos.deployment_target = "4.0"
  s.tvos.deployment_target = "10.0"

  s.source       = { :http => "http://iamapps.net/HoneyBee/1.11.0/HoneyBee-1.11.0.zip"}

  s.source_files = "HoneyBee/*"

end	

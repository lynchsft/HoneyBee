
Pod::Spec.new do |s|
  s.name         = "HoneyBee"
  s.version      = "1.4.1"
  s.summary      = "A swift library to increase the expressiveness of asynchronous and multi-parallel code."

  s.description  = <<-DESC
	HoneyBee reduces the clutter and complexity of asynchronous and multi-parallel code. 
	By handing the noise of data routing and error handling, HoneyBee provides a higher-level, more expressive perspective on asynchronous programming.
                   DESC

  s.homepage     = "http://iamapps.net/HoneyBee/1.4.1/docs/index.html"

  s.license      = { :type=>"MIT", :file => 'LICENSE' }

  s.author       = { "Alex Lynch" => "alex@iamapps.com" }

  s.ios.deployment_target = "9.0"
  #s.osx.deployment_target = "10.7"
  #s.watchos.deployment_target = "2.0"
  #s.tvos.deployment_target = "9.0"

  s.source       = { :http => "http://iamapps.net/HoneyBee/1.4.1/HoneyBee-1.4.1.zip"}

  s.source_files = "HoneyBee/*.swift"

end	

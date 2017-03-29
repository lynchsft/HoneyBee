
Pod::Spec.new do |s|
  s.name         = "HoneyBee"
  s.version      = "0.1.7"
  s.summary      = "A swift library to increase the expressiveness of asynchronous and multi-parallel code."

  s.description  = <<-DESC
	HoneyBee reduces the clutter and complexity of asynchronous and multi-parallel code. 
	By handing the noise of data routing and error handling, HoneyBee provides a higher-level, more expressive perspective on asynchronous programming.
                   DESC

  s.homepage     = "http://iamapps.net/HoneyBee/0.1.7/docs/index.html"

  s.license      = { :type=>"Commercial" }

  s.author       = { "Alex Lynch" => "alex@iamapps.com" }

  s.ios.deployment_target = "9.0"
  #s.osx.deployment_target = "10.7"
  #s.watchos.deployment_target = "2.0"
  #s.tvos.deployment_target = "9.0"

  s.source       = { :http => "http://iamapps.net/HoneyBee/0.1.7/HoneyBee-0.1.7.zip"}

  s.vendored_frameworks = 'HoneyBee.framework', 'CommonCrypto.framework'

end	

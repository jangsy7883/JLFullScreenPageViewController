Pod::Spec.new do |s|
  s.name         = "JLFullScreenPageViewController"
  s.version      = "1.2"
  s.summary      = "JLFullScreenPageViewController"
  s.homepage     = "https://github.com/jangsy7883/JLFullScreenPageViewController"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "hmhv" => "jangsy7883@gmail.com" }
  s.source       = { :git => "https://github.com/jangsy7883/JLFullScreenPageViewController.git", :tag => s.version }
  s.source_files = 'JLFullScreenPageViewController/*.{h,m}','JLFullScreenPageViewController/Categorys/*.{h,m}'
  s.requires_arc = true
  s.ios.deployment_target = '8.0'
  s.dependency 'JLPageViewController'
end

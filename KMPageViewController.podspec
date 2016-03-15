@version = "0.1.13"
Pod::Spec.new do |s|
  s.name         = "KMPageViewController"
  s.version      = @version
  s.summary      = "KMPageViewController"
  s.homepage     = "https://github.com/jangsy7883/KMPageViewController"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "hmhv" => "jangsy7883@gmail.com" }
  s.source       = { :git => "https://github.com/jangsy7883/KMPageViewController.git", :tag => @version }
  s.source_files = 'KMPageViewController/*.{h,m}','KMPageViewController/Categorys/*.{h,m}'
  s.requires_arc = true
  s.ios.deployment_target = '7.0'
end
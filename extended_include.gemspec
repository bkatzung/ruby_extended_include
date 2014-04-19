Gem::Specification.new do |s|
  s.name	= "extended_include"
  s.version	= "0.0.2"
  s.date	= "2014-04-18"
  s.authors	= ["Brian Katzung"]
  s.email	= ["briank@kappacs.com"]
  s.homepage	= "http://rubygems.org/gems/extended_include"
  s.summary	= "Include both class and instance methods on module include"
  s.description	= "This module assists with some of the finer details in the extend-on-included idiom for importing class methods in addition to instance methods when including a module."
  s.license	= "Public Domain"
 
  s.files        = Dir.glob("lib/**/*") +
  		   %w{extended_include.gemspec .yardopts HISTORY.txt}
  s.test_files   = Dir.glob("test/**/*.rb")
  s.require_path = 'lib'
end

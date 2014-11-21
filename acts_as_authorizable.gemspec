$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'acts_as_authorizable/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name                  = 'acts_as_authorizable'
  s.version               = NekoNova::ActsAsAuthorizable::VERSION
  s.authors               = ['Matthew Leventi', 'Arne De Herdt']
  s.email                 = ['arne.de.herdt@gmail.com']
  s.homepage              = 'https://github.com/NekoNova/acts_as_slugable'
  s.summary               = 'Gem that implements the old behavior of acts_as_authorizable plugin.'
  s.description           = 'This gem is an attempt at converting an old Plugin into a Gem.'
  s.license               = 'MIT'
  s.platform              = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.1'
  s.files                 = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']
  s.test_files            = Dir['test/**/*']


  s.add_dependency 'rails', '~> 4.1'

  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'factory_girl'
end
$:.push File.expand_path("../lib", __FILE__)
require './lib/arroyo/version'

Gem::Specification.new do |s|
  s.name        = "arroyo-client"
  s.version     = Arroyo::VERSION.dup
  s.authors     = ["Adam Hiatt"]
  s.email       = ["adam@taoit.com"]
  s.homepage    = "https://github.com/GoodGuide/arroyo-client"
  s.summary     = "Arroyo ESB API client gem"
  s.description = "Gem to access all aspects of the Arroyo ESB REST API"
#  s.rubyforge_project = "arroyo"
  s.files = Dir['Gemfile', 'arroyo-client.gemspec', 'lib/**/*.rb']

  s.add_dependency('faraday', '~> 0.8')
  s.add_dependency('faraday_middleware')
  s.add_dependency('yajl-ruby')
  s.add_dependency('typhoeus')
  s.add_dependency('hashie')  
end

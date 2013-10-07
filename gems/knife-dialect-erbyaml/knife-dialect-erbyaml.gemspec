$:.unshift(File.dirname(__FILE__) + '/lib')
require 'knife-dialect-erbyaml/version'

Gem::Specification.new do |s|
  s.name = 'knife-dialect-erbyaml'
  s.version = KnifeDialectErbYaml::VERSION
  s.platform = Gem::Platform::RUBY
  s.author = 'Noah Kantrowitz'
  s.email = 'noah@coderanger.net'
  s.summary = 'Dialect to provide ERB-templated Yaml for Chef input'

  #s.add_dependency ''

  s.require_path = 'lib'
  s.files = %w(Rakefile LICENSE README.md CONTRIBUTING.md) + Dir.glob('{distro,lib,tasks,spec}/**/*', File::FNM_DOTMATCH).reject {|f| File.directory?(f) }
end

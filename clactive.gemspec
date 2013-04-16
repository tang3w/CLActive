Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY

  s.name     = 'clactive'
  s.version  = '0.0.10'
  s.license  = 'MIT'
  s.email    = 'tang3w@gmail.com'
  s.author   = 'Tang Tianyong'
  s.homepage = 'http://tang3w.com'

  s.summary     = 'Command line helper'
  s.description = 'CLActive help you to build command quickly'

  s.files = Dir['lib/**/*.rb']
  s.require_paths = %w(lib)
end

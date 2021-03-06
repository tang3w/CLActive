Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY

  s.name     = 'clactive'
  s.version  = '0.1.0'
  s.license  = 'MIT'
  s.email    = 'tang3w@gmail.com'
  s.author   = 'Tang Tianyong'
  s.homepage = 'https://github.com/tang3w/CLActive'

  s.summary     = 'Command line helper'
  s.description = 'CLActive help you to build command quickly'

  s.files = Dir['lib/**/*.rb']
  s.require_paths = %w(lib)
end

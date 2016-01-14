Gem::Specification.new do |gem|
  gem.name          = "fluent-plugin-docker-inspect"
  gem.version       = File.read("VERSION").strip

  gem.authors       = ["WAKAYAMA Shirou"]
  gem.email         = ["shirou.faw@gmail.com"]
  gem.description   = ''
  gem.summary       = gem.description
  gem.homepage      = "https://github.com/shirou/fluent-plugin-docker-inspect"
  gem.license       = 'MIT'
  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.has_rdoc = false
  gem.required_ruby_version = '>= 1.9.2'

  gem.add_dependency "fluentd", ">= 0.10.33"
  gem.add_development_dependency "rake", ">= 0.9.2"
  gem.add_development_dependency "simplecov", ">= 0.5.4"
  gem.add_development_dependency "rr", ">= 1.0.0"
end

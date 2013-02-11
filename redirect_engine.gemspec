# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'redirect_engine/version'

Gem::Specification.new do |gem|
  gem.name          = "redirect_engine"
  gem.version       = RedirectEngine::VERSION
  gem.authors       = ["Christoph Trautwein"]
  gem.email         = ["trautwein@scienitst.com"]
  gem.description   = %q{Generates http redirects}
  gem.summary       = %q{Usefil together with some Apache config and the redirect-backoffice}
  gem.homepage      = "http://chtw.de/redirector"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "sinatra"
end

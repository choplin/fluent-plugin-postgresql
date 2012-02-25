# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "fluent-plugin-postgresql/version"

Gem::Specification.new do |s|
  s.name        = "fluent-plugin-postgresql"
  s.version     = 0.0.1
  s.authors     = ["choplin"]
  s.email       = ["choplin.public@gmail.com"]
  s.homepage    = "https://github.com/choplin/fluent-plugin-postgresql"
  s.summary     = %q{fluentd plugin to work with PostgreSQL}
  s.description = %q{fluentd plugin to work with PostgreSQL}

  s.rubyforge_project = "fluent-plugin-postgresql"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end

# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "act_as_dirty/version"

Gem::Specification.new do |s|
  s.name        = "act_as_dirty"
  s.version     = ActAsDirty::VERSION
  s.authors     = ["Mathieu Gagne"]
  s.email       = ["mathieu@orangebrule.com"]
  s.homepage    = "http://github.com/orangebrule/act-as-dirty"
  s.summary     = %q{Create a message of all changes made to a record each time it saves using ActiveModel::Dirty. }
  s.description = %q{Keep a log of what every user does on your system. Very useful in CRM, it would allow you to easily keep track of what every user has done to the record.}

  s.rubyforge_project = "act_as_dirty"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end

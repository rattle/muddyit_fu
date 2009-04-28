Gem::Specification.new do |s|
  s.name     = "muddyit_fu"
  s.version  = "0.0.2"
  s.date     = "2009-04-27"
  s.summary  = "Provides a ruby interface to muddy.it via the REST api"
  s.email    = "robl at monkeyhelper.com"
  s.homepage = "http://github.com/monkeyhelper/muddyit_fu"
  s.description = "Provides a ruby interface to muddy.it via the REST api"
  s.has_rdoc = false
  s.authors  = ["Rob Lee"]
  s.files = Dir['lib/**/*.rb']
  s.rdoc_options = ["--main", "README"]
  s.extra_rdoc_files = ["README"]
  s.add_dependency("json", ["> 0.0.0"])
end


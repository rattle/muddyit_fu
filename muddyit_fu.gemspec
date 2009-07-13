# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{muddyit_fu}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["robl"]
  s.date = %q{2009-07-13}
  s.email = %q{robl[at]monkeyhelper.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".gitignore",
     "CHANGELOG",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "lib/muddyit/base.rb",
     "lib/muddyit/entity.rb",
     "lib/muddyit/errors.rb",
     "lib/muddyit/generic.rb",
     "lib/muddyit/sites.rb",
     "lib/muddyit_fu.rb",
     "muddyit_fu.gemspec"
  ]
  s.homepage = %q{http://github.com/monkeyhelper/muddyit_fu}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{Provides a ruby interface to muddy.it}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<json>, [">= 0.0.0"])
    else
      s.add_dependency(%q<json>, [">= 0.0.0"])
    end
  else
    s.add_dependency(%q<json>, [">= 0.0.0"])
  end
end

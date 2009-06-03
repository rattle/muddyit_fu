# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{muddyit_fu}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["robl"]
  s.date = %q{2009-06-03}
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
     "lib/muddyit/content_data.rb",
     "lib/muddyit/entity.rb",
     "lib/muddyit/errors.rb",
     "lib/muddyit/generic.rb",
     "lib/muddyit/page.rb",
     "lib/muddyit/pages.rb",
     "lib/muddyit/site.rb",
     "lib/muddyit/sites.rb",
     "lib/muddyit_fu.rb",
     "muddyit_fu.gemspec"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/monkeyhelper/muddyit_fu}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Provides a ruby interface to muddy.it}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

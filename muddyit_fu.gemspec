# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{muddyit_fu}
  s.version = "0.2.10"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["rattle"]
  s.date = %q{2010-01-11}
  s.email = %q{support[at]muddy.it}
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
     "examples/newsindexer.rb",
     "examples/oauth.rb",
     "lib/muddyit/base.rb",
     "lib/muddyit/collections.rb",
     "lib/muddyit/collections/collection.rb",
     "lib/muddyit/collections/entities.rb",
     "lib/muddyit/collections/entities/entity.rb",
     "lib/muddyit/collections/pages.rb",
     "lib/muddyit/collections/pages/page.rb",
     "lib/muddyit/collections/pages/page/extracted_content.rb",
     "lib/muddyit/entities.rb",
     "lib/muddyit/errors.rb",
     "lib/muddyit/generic.rb",
     "lib/muddyit/oauth.rb",
     "lib/muddyit_fu.rb",
     "muddyit_fu.gemspec",
     "test/config.yml.example",
     "test/test_helper.rb",
     "test/test_muddyit_fu.rb"
  ]
  s.homepage = %q{http://github.com/rattle/muddyit_fu}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Provides a ruby interface to muddy.it}
  s.test_files = [
    "test/test_muddyit_fu.rb",
     "test/test_helper.rb",
     "examples/newsindexer.rb",
     "examples/oauth.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<json>, [">= 0.0.0"])
      s.add_runtime_dependency(%q<oauth>, [">= 0.3.6"])
    else
      s.add_dependency(%q<json>, [">= 0.0.0"])
      s.add_dependency(%q<oauth>, [">= 0.3.6"])
    end
  else
    s.add_dependency(%q<json>, [">= 0.0.0"])
    s.add_dependency(%q<oauth>, [">= 0.3.6"])
  end
end

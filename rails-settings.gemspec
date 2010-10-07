# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rails-settings}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Squeegy", "Georg Ledermann", "100hz"]
  s.date = %q{2010-10-07}
  s.email = %q{rails-settings@theblackestbox.net}
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    ".project",
     "MIT-LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "lib/generators/settings/settings_generator.rb",
     "lib/generators/settings/templates/migration.rb",
     "lib/generators/settings/templates/model.rb",
     "lib/rails-settings.rb",
     "lib/rails-settings/railtie.rb",
     "lib/rails-settings/scoped_settings.rb",
     "lib/rails-settings/settings.rb",
     "rails-settings.gemspec",
     "rails/init.rb"
  ]
  s.homepage = %q{http://theblackestbox.net}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Settings is a plugin that makes managing a table of global key, value pairs easy. Think of it like a global Hash stored in you database, that uses simple ActiveRecord like methods for manipulation.  Keep track of any global setting that you dont want to hard code into your rails app.  You can store any kind of object.  Strings, numbers, arrays, or any object. Ported to Rails 3!}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails>, [">= 3.0.0"])
    else
      s.add_dependency(%q<rails>, [">= 3.0.0"])
    end
  else
    s.add_dependency(%q<rails>, [">= 3.0.0"])
  end
end

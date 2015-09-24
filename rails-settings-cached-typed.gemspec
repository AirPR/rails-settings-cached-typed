# coding: utf-8
Gem::Specification.new do |s|
  s.name = 'rails-settings-cached-typed'
  s.version = '0.1.0'

  s.required_rubygems_version = Gem::Requirement.new('>= 0') if s.respond_to? :required_rubygems_version=
  s.authors = ['Squeegy', 'Georg Ledermann', '100hz', 'Jason Lee', 'Adib Saad']
  s.email = 'adib.saad@gmail.com'
  s.files = Dir.glob('lib/**/*') + %w(README.md)
  s.homepage = 'https://github.com/AirPR/rails-settings-cached-typed'
  s.require_paths = ['lib']
  s.summary = 'Carrying on from rails-settings-cached, this gem requires explicit type decelerations for settings.'

  s.add_dependency 'rails', '>= 4.2.0'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '>= 3.3.0'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'sqlite3', '>= 1.3.10'
end

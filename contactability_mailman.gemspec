# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

# this gemspec was mostly stolen from bundler

require 'contactability_mailman/version'

Gem::Specification.new do |s|
  s.name        = 'contactability_mailman'
  s.version     = '0.5.3'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Jonathan Rudenberg']
  s.email       = ['jonathan@titanous.com']
  s.homepage    = 'http://mailmanrb.com'
  s.summary     = 'A incoming email processing microframework'
  s.description = 'Contactability Mailman makes it easy to process incoming emails with a simple routing DSL'

  s.rubyforge_project = 'contactability_mailman'

  s.add_dependency 'mail', '>= 2.0.3'
  s.add_dependency 'activesupport', '>= 2.3.4'
  s.add_dependency 'listen', '>= 0.4.1'
  s.add_dependency 'maildir', '>= 0.5.0'
  s.add_dependency 'i18n', '>= 0.4.1' # fix for mail/activesupport-3 dependency issue

  s.add_development_dependency 'rspec', '~> 2.10'

  s.files        = Dir.glob('{bin,lib,examples}/**/*') + %w(LICENSE README.md USER_GUIDE.md)
  s.require_path = 'lib'
end
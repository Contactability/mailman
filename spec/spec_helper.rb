$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'fileutils'
require 'contactability_mailman'
require 'rspec'
require 'maildir'

# Require all files in spec/support (Mocks, helpers, etc.)
Dir[File.join(File.dirname(__FILE__), "support", "**", "*.rb")].each do |f|
  require File.expand_path(f)
end

unless defined?(SPEC_ROOT)
  SPEC_ROOT = File.join(File.dirname(__FILE__))
end

unless defined?(THREAD_TIMING)
  THREAD_TIMING = (ENV['THREAD_TIMING'] || (defined?(RUBY_ENGINE) && (RUBY_ENGINE == 'jruby' || RUBY_ENGINE == 'rbx') ? 2.5 : 2)).to_f
end

module ContactabilityMailman::SpecHelpers

  def regexp_matcher(pattern)
    ContactabilityMailman::Route::RegexpMatcher.new(pattern)
  end

  def string_matcher(pattern)
    ContactabilityMailman::Route::StringMatcher.new(pattern)
  end

  def basic_message
    Mail.new("To: test@example.com\r\nFrom: chunky@bacon.com\r\nCC: testing@example.com\r\nSubject: Hello!\r\n\r\nemail message\r\n")
  end

  def ContactabilityMailman_app(&block)
    @app = ContactabilityMailman::Application.new(&block)
  end

  def send_message(message)
    @app.router.route Mail.new(message)
  end

  def config
    ContactabilityMailman.config
  end

  def fixture(*name)
    File.open(File.join(SPEC_ROOT, 'fixtures', name) + '.eml').read
  end

  def setup_maildir
    maildir_path = File.join(SPEC_ROOT, 'test-maildir')
    FileUtils.rm_r(maildir_path) rescue nil
    @maildir = Maildir.new(maildir_path)
    message = File.new(File.join(maildir_path, 'new', 'message1'), 'w')
    message.puts(fixture('example01'))
    message.close
  end

end

RSpec.configure do |config|
  config.include ContactabilityMailman::SpecHelpers
  config.before do
    ContactabilityMailman.config.logger = Logger.new(File.join(SPEC_ROOT, 'contactability-mailman-log.log'))
  end
  config.after do
    FileUtils.rm File.join(SPEC_ROOT, 'contactability-mailman-log.log') rescue nil
  end
end


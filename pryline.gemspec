# frozen_string_literal: true

require File.dirname(__FILE__) + "/lib/version"

Gem::Specification.new do |gem|
  gem.name = "pryline"
  gem.version = Pryline::VERSION
  gem.authors = ["Brian Graham"]
  gem.email = "bcgraham+github@gmail.com"
  gem.license = "MIT"
  gem.homepage = "https://github.com/bcgraham/pryline"
  gem.summary = "Extend Readline interface to more functions."
  gem.description = "Adds rl_bind_key, rl_bind_keyseq, rl_newline, rl_unbind_key, rl_unbind_keyseq."

  gem.files = Dir["lib/**/*.rb", "LICENSE"]
  gem.extra_rdoc_files = %w[]
  gem.require_path = "lib"
  gem.executables = []

  # Dependencies
  gem.required_ruby_version = ">= 2.3.0"

  gem.requirements << "Readline 8.0"
end

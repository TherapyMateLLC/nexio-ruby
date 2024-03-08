# frozen_string_literal: true

require_relative "lib/nexio/version"

Gem::Specification.new do |spec|
  spec.name = "nexio"
  spec.version = Nexio::VERSION
  spec.authors = ["TherapyMate", "James Carbine", "Abdul Barek"]
  spec.email = ["jamescarbine@gmail.com", "barek2k2@gmail.com"]

  spec.summary = "Nexio integration with Ruby on Rails"
  spec.homepage = "https://github.com/TherapyMateLLC/nexio-rails"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org/"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/TherapyMateLLC/nexio-rails"
  spec.metadata["changelog_uri"] = "https://github.com/TherapyMateLLC/nexio-rails/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
   spec.add_dependency "vcr"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end

# frozen_string_literal: true

require_relative "lib/dev_onboarder/version"

Gem::Specification.new do |spec|
  spec.name = "dev_onboarder"
  spec.version = DevOnboarder::VERSION
  spec.authors = ["tylercschneider"]
  spec.email = ["tylercschneider@gmail.com"]

  spec.summary = "One setup command that gets a developer from a fresh clone to a working repo."
  spec.description = "dev_onboarder reads a repo's Setupfile, checks each requirement it lists, " \
                     "runs the fix for each one that is not met, and records what it found " \
                     "in the clone."
  spec.homepage = "https://github.com/DYB-Development/dev_onboarder"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "#{spec.homepage}/tree/main"
  spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/issues"
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore test/ .github/ .rubocop.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end

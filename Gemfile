# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "rake", "~> 13.0"

gem "minitest", "~> 5.16"

gem "rubocop", "~> 1.21"
gem "rubocop-minitest", require: false
gem "rubocop-rake", require: false
# parallel 2.x (a RuboCop dependency) requires Ruby >= 3.3; pin below it so the
# dev toolchain still resolves on Ruby 3.2, which we support and test.
gem "parallel", "< 2"

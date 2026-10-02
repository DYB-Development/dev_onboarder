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

# Only needed to test the setup page, which a Rails app shows. The setup command
# itself needs no Rails, and the gem loads its engine only inside a Rails app.
gem "keystone_ui", ">= 0.9"
gem "railties", ">= 7.1"
# rdoc 8 (a Rails dependency through irb) needs rbs 4, which requires Ruby >= 3.3;
# pin below it so the bundle still installs on Ruby 3.2, which we support and test.
gem "rdoc", "< 8"

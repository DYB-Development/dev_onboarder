# frozen_string_literal: true

require_relative "dev_onboarder/version"

module DevOnboarder
  class Error < StandardError; end
end

require_relative "dev_onboarder/engine" if defined?(Rails::Engine)

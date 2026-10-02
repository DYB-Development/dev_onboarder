# frozen_string_literal: true

require "rails/engine"
require "keystone_ui"
require_relative "overview"
require_relative "requirements"

module DevOnboarder
  class Engine < ::Rails::Engine
    isolate_namespace DevOnboarder
  end
end

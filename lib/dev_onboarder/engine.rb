# frozen_string_literal: true

require "rails/engine"
require "keystone_ui"
require_relative "overview"
require_relative "requirements"

module DevOnboarder
  class << self
    attr_writer :base_controller

    def base_controller
      @base_controller || "ActionController::Base"
    end
  end

  class Engine < ::Rails::Engine
    isolate_namespace DevOnboarder
  end
end

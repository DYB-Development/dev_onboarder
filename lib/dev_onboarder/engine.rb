# frozen_string_literal: true

require "rails/engine"
require "keystone_ui"
require_relative "env_file"
require_relative "overview"
require_relative "record_location"
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

    initializer "dev_onboarder.load_environment_file", before: :load_config_initializers do |app|
      EnvFile.new(app.root.join(".env").to_s).load_into(ENV) if Rails.env.development?
    end

    initializer "dev_onboarder.page_route" do |app|
      app.routes.prepend { mount DevOnboarder::Engine, at: "/dev_onboarder" if Rails.env.local? }
    end

    server do
      notice = startup_notice(Rails.root.to_s) if Rails.env.local?
      puts notice if notice
    end

    def self.startup_notice(root)
      return unless File.exist?(File.join(root, "Setupfile"))

      overview(root).notice
    end

    def self.overview(root)
      Overview.new(requirements: Requirements.load(File.join(root, "Setupfile")),
                   record: Record.new(RecordLocation.path(root)))
    end
  end
end

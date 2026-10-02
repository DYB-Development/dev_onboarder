# frozen_string_literal: true

require "rails"
require "action_controller/railtie"
require "keystone_ui"
require "dev_onboarder/engine"
require "tmpdir"

class HostApp < Rails::Application
  config.root = Dir.mktmpdir
  config.eager_load = false
  config.secret_key_base = "a secret used only by the gem's own tests"
  config.hosts.clear
  config.logger = Logger.new(nil)
end

HostApp.initialize!
HostApp.routes.draw { mount DevOnboarder::Engine, at: "/setup" }

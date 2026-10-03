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

class ApplicationController < ActionController::Base
  layout "host"
end

DevOnboarder.base_controller = "ApplicationController"

File.write(HostApp.root.join(".env"), "DEV_ONBOARDER_HOST_KEY=from the env file\n")
FileUtils.mkdir_p(HostApp.root.join("app/views/layouts"))
File.write(HostApp.root.join("app/views/layouts/host.html.erb"), '<body data-layout="host"><%= yield %></body>')

HostApp.initialize!
HostApp.routes.draw { mount DevOnboarder::Engine, at: "/setup" }

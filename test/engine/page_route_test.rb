# frozen_string_literal: true

require "test_helper"
require "support/host_app"
require "action_dispatch/testing/integration"

module DevOnboarder
  class PageRouteTest < ActionDispatch::IntegrationTest
    def setup
      File.write(Rails.root.join("Setupfile"),
                 'requirement :databases, group: :repo_setup, purpose: "Databases exist", check: "check-db"')
    end

    def teardown
      FileUtils.rm_f(Rails.root.join("Setupfile"))
    end

    def test_a_local_app_has_the_setup_page_without_drawing_a_route_for_it
      get "/dev_onboarder"

      assert_response :success
    end

    def test_an_app_running_in_production_has_no_setup_page
      Rails.stub(:env, ActiveSupport::EnvironmentInquirer.new("production")) { Rails.application.reload_routes! }
      get "/dev_onboarder"

      assert_response :not_found
    ensure
      Rails.application.reload_routes!
    end
  end
end

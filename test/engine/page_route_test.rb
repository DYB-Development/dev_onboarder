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
  end
end

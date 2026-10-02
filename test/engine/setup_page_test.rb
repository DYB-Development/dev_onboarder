# frozen_string_literal: true

require "test_helper"
require "support/host_app"
require "action_dispatch/testing/integration"

module DevOnboarder
  class SetupPageTest < ActionDispatch::IntegrationTest
    SETUPFILE = <<~RUBY
      requirement :databases, group: :repo_setup, purpose: "Databases exist", check: "check-db"
      feature :payments, "Take a test payment" do
        requirement :payment_key, group: :secrets, purpose: "Payment test key is set", check: "check-key"
      end
    RUBY

    def setup
      File.write(Rails.root.join("Setupfile"), SETUPFILE)
    end

    def teardown
      FileUtils.rm_f([Rails.root.join("Setupfile"), Rails.root.join(".dev_onboarder.json")])
    end

    def test_the_page_lists_a_requirement_with_what_it_is_for
      get "/setup"

      assert_includes response.body, "Databases exist"
    end

    def test_the_page_names_each_group_of_requirements
      get "/setup"

      assert_includes response.body, "Repo setup"
    end
  end
end

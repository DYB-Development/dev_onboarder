# frozen_string_literal: true

require "test_helper"
require "support/host_app"
require "action_dispatch/testing/integration"

module DevOnboarder
  class SetupPageTest < ActionDispatch::IntegrationTest
    CHECKED_AT = Time.utc(2026, 10, 2, 14, 30)
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

    def record_everything_met
      requirements = Requirements.load(Rails.root.join("Setupfile").to_s)
      results = requirements.to_h do |requirement|
        [requirement.key, Result.new(met: true, checked_at: CHECKED_AT, fingerprint: requirement.fingerprint)]
      end
      Record.new(Rails.root.join(".dev_onboarder.json").to_s).save(results)
    end

    def test_the_page_lists_a_requirement_with_what_it_is_for
      get "/setup"

      assert_includes response.body, "Databases exist"
    end

    def test_the_page_names_each_group_of_requirements
      get "/setup"

      assert_includes response.body, "Repo setup"
    end

    def test_the_page_marks_a_requirement_no_run_has_recorded_as_new
      get "/setup"

      assert_select "td", text: "New"
    end

    def test_the_page_says_a_requirement_no_run_has_recorded_was_never_checked
      get "/setup"

      assert_select "td", text: "Never"
    end

    def test_the_page_warns_how_many_requirements_need_a_setup_run
      get "/setup"

      assert_includes response.body, "dev_onboarder: 1 requirement needs setup. Run bundle exec dev_onboarder."
    end

    def test_the_page_says_so_when_everything_outside_a_feature_is_set_up
      record_everything_met
      get "/setup"

      assert_includes response.body, "Everything outside a feature is set up."
    end

    def test_the_page_shows_the_command_that_sets_up_what_is_missing
      get "/setup"

      assert_select "code", text: "bundle exec dev_onboarder"
    end

    def test_the_page_lists_each_feature_with_what_it_is
      get "/setup"

      assert_select "td", text: "Take a test payment"
    end

    def test_the_page_marks_a_feature_whose_requirement_is_not_met_as_not_ready
      get "/setup"

      assert_select "td", text: "Not ready"
    end

    def test_the_page_marks_a_feature_whose_requirements_are_met_as_ready
      record_everything_met
      get "/setup"

      assert_select "td", text: "Ready"
    end

    def test_the_page_is_titled_setup
      get "/setup"

      assert_select "h1", text: "Setup"
    end

    def test_the_page_is_drawn_inside_the_layout_of_the_controller_the_app_names
      get "/setup"

      assert_select "body[data-layout=host]"
    end
  end
end

# frozen_string_literal: true

require "test_helper"
require "dev_onboarder/overview"
require "dev_onboarder/requirements"
require "tmpdir"

module DevOnboarder
  class OverviewTest < Minitest::Test
    CHECKED_AT = Time.utc(2026, 10, 2, 14, 30)
    SETUPFILE = <<~RUBY
      requirement :databases, group: :repo_setup, purpose: "Databases exist", check: "check-db"
      requirement :seeds, group: :repo_setup, purpose: "Seed data is loaded", check: "check-seeds"
      feature :payments, "Take a test payment" do
        requirement :payment_key, group: :secrets, purpose: "Payment test key is set", check: "check-key"
      end
    RUBY

    def setup
      @dir = Dir.mktmpdir
      File.write(File.join(@dir, "Setupfile"), SETUPFILE)
      @requirements = Requirements.load(File.join(@dir, "Setupfile"))
      @record = Record.new(File.join(@dir, ".dev_onboarder.json"))
    end

    def teardown
      FileUtils.remove_entry(@dir)
    end

    def test_requirements_are_listed_under_one_entry_for_each_group
      assert_equal %i[repo_setup secrets], overview.groups.map(&:name)
    end

    def test_a_requirement_no_run_has_recorded_is_listed_as_new
      assert_equal :new, overview.groups.first.rows.first.state
    end

    def test_a_requirement_the_last_run_met_is_listed_as_met
      record_met(:databases)

      assert_equal :met, overview.groups.first.rows.first.state
    end

    def test_a_requirement_is_listed_with_when_it_was_last_checked
      record_met(:databases)

      assert_equal CHECKED_AT, overview.groups.first.rows.first.checked_at
    end

    def test_a_feature_whose_requirement_is_not_met_is_not_ready
      refute overview.features.first.ready
    end

    def test_a_feature_whose_requirements_the_last_run_met_is_ready
      record_met(:payment_key)

      assert overview.features.first.ready
    end

    def test_there_is_no_notice_when_every_requirement_outside_a_feature_is_met_and_unchanged
      record_met(:databases, :seeds)

      assert_nil overview.notice
    end

    def test_the_notice_counts_the_requirements_that_need_a_setup_run_and_names_the_command
      record_met(:databases)

      assert_equal "dev_onboarder: 1 requirement needs setup. Run bundle exec dev_onboarder.", overview.notice
    end

    private

    def overview
      Overview.new(requirements: @requirements, record: @record)
    end

    def record_met(*keys)
      results = @requirements.select { |requirement| keys.include?(requirement.key) }.to_h do |requirement|
        [requirement.key, Result.new(met: true, checked_at: CHECKED_AT, fingerprint: requirement.fingerprint)]
      end
      @record.save(results)
    end
  end
end

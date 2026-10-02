# frozen_string_literal: true

require "test_helper"
require "dev_onboarder/status"
require "tmpdir"

module DevOnboarder
  class StatusTest < Minitest::Test
    CHECKED_AT = Time.utc(2026, 10, 2, 14, 30)

    def setup
      @dir = Dir.mktmpdir
      @record = Record.new(File.join(@dir, ".dev_onboarder.json"))
      @requirement = Requirement.new(key: :databases, group: :repo_setup, purpose: "Databases exist",
                                     check: "check-db")
    end

    def teardown
      FileUtils.remove_entry(@dir)
    end

    def test_a_requirement_with_no_recorded_result_is_new
      assert_equal [:new], states
    end

    def test_a_requirement_met_and_unchanged_since_the_last_run_is_not_listed
      record_result(met: true, fingerprint: @requirement.fingerprint)

      assert_empty states
    end

    def test_a_requirement_whose_definition_changed_since_the_last_run_is_changed
      record_result(met: true, fingerprint: "the fingerprint of an earlier definition")

      assert_equal [:changed], states
    end

    private

    def states
      Status.new(requirements: [@requirement], record: @record).call.map(&:state)
    end

    def record_result(met:, fingerprint:)
      @record.save(databases: Result.new(met: met, checked_at: CHECKED_AT, fingerprint: fingerprint))
    end
  end
end

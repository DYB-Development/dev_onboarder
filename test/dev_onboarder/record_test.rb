# frozen_string_literal: true

require "test_helper"
require "dev_onboarder/record"
require "tmpdir"

module DevOnboarder
  class RecordTest < Minitest::Test
    CHECKED_AT = Time.utc(2026, 10, 2, 14, 30)

    def setup
      @dir = Dir.mktmpdir
      @path = File.join(@dir, ".dev_onboarder.json")
    end

    def teardown
      FileUtils.remove_entry(@dir)
    end

    def test_a_saved_result_is_read_back_as_met
      Record.new(@path).save(databases: Result.new(met: true, checked_at: CHECKED_AT))

      assert Record.new(@path).result_for(:databases).met
    end

    def test_a_saved_result_is_read_back_with_the_time_it_was_checked
      Record.new(@path).save(databases: Result.new(met: true, checked_at: CHECKED_AT))

      assert_equal CHECKED_AT, Record.new(@path).result_for(:databases).checked_at
    end

    def test_a_clone_with_no_setup_record_has_no_result_for_a_requirement
      assert_nil Record.new(@path).result_for(:databases)
    end

    def test_a_saved_result_is_read_back_with_its_fingerprint
      Record.new(@path).save(databases: Result.new(met: true, checked_at: CHECKED_AT, fingerprint: "abc123"))

      assert_equal "abc123", Record.new(@path).result_for(:databases).fingerprint
    end

    def test_saving_a_result_keeps_the_results_already_recorded
      Record.new(@path).save(databases: Result.new(met: true, checked_at: CHECKED_AT))
      Record.new(@path).save(payment_key: Result.new(met: false, checked_at: CHECKED_AT))

      assert Record.new(@path).result_for(:databases).met
    end
  end
end

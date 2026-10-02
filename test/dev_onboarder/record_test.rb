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
  end
end

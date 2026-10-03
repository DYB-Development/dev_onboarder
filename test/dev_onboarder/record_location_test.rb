# frozen_string_literal: true

require "test_helper"
require "dev_onboarder/record_location"
require "tmpdir"

module DevOnboarder
  class RecordLocationTest < Minitest::Test
    def setup
      @dir = File.realpath(Dir.mktmpdir)
    end

    def teardown
      FileUtils.remove_entry(@dir)
    end

    def test_a_repo_outside_git_keeps_its_setup_record_at_its_root
      assert_equal File.join(@dir, ".dev_onboarder.json"), RecordLocation.path(@dir)
    end
  end
end

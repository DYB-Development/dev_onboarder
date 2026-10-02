# frozen_string_literal: true

require "test_helper"
require "dev_onboarder/env_file"
require "tmpdir"

module DevOnboarder
  class EnvFileTest < Minitest::Test
    def setup
      @dir = Dir.mktmpdir
      @path = File.join(@dir, ".env")
    end

    def teardown
      FileUtils.remove_entry(@dir)
    end

    def test_a_value_that_is_set_is_written_as_a_line_of_the_file
      EnvFile.new(@path).set("PRICE_KEY", "abc123")

      assert_equal "PRICE_KEY=abc123\n", File.read(@path)
    end
  end
end

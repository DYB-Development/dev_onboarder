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

    def test_setting_a_value_keeps_the_values_already_in_the_file
      EnvFile.new(@path).set("PRICE_KEY", "abc123")
      EnvFile.new(@path).set("MAP_KEY", "xyz789")

      assert_equal "PRICE_KEY=abc123\nMAP_KEY=xyz789\n", File.read(@path)
    end

    def test_loading_the_file_puts_its_values_into_the_environment
      EnvFile.new(@path).set("PRICE_KEY", "abc123")
      environment = {}
      EnvFile.new(@path).load_into(environment)

      assert_equal({ "PRICE_KEY" => "abc123" }, environment)
    end
  end
end

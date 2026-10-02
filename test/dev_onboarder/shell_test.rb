# frozen_string_literal: true

require "test_helper"
require "dev_onboarder/shell"

module DevOnboarder
  class ShellTest < Minitest::Test
    def test_a_command_that_exits_zero_succeeds
      assert Shell.new.succeeds?("exit 0")
    end

    def test_a_command_that_exits_non_zero_does_not_succeed
      refute Shell.new.succeeds?("exit 3")
    end

    def test_running_a_command_returns_what_it_printed
      assert_equal "to the output\n", Shell.new.run("echo to the output").output
    end

    def test_running_a_command_that_exits_non_zero_does_not_succeed
      refute Shell.new.run("exit 3").success
    end

    def test_a_command_that_runs_past_its_time_limit_is_stopped
      refute Shell.new.run("sleep 3", timeout: 0.2).success
    end
  end
end

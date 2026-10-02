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
  end
end

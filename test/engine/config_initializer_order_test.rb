# frozen_string_literal: true

require "test_helper"
require "support/host_app"

module DevOnboarder
  class ConfigInitializerOrderTest < Minitest::Test
    def test_an_app_reads_the_stored_values_while_its_own_initializers_run
      assert_equal "from the env file", Rails.configuration.x.read_by_an_initializer
    end
  end
end

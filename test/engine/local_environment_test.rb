# frozen_string_literal: true

require "test_helper"
require "support/host_app"

module DevOnboarder
  class LocalEnvironmentTest < Minitest::Test
    def test_an_app_started_in_development_has_the_values_stored_in_its_environment_file
      assert_equal "from the env file", ENV.fetch("DEV_ONBOARDER_HOST_KEY", nil)
    end
  end
end

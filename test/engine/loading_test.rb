# frozen_string_literal: true

require "test_helper"
require "open3"

module DevOnboarder
  class LoadingTest < Minitest::Test
    LIB = File.expand_path("../../lib", __dir__)

    def test_requiring_the_gem_inside_a_rails_app_with_keystone_ui_loads_the_page
      script = 'require "rails"; require "keystone_ui"; require "dev_onboarder"; print defined?(DevOnboarder::Engine)'
      output, = Open3.capture2e("ruby", "-I", LIB, "-e", script)

      assert_equal "constant", output
    end
  end
end

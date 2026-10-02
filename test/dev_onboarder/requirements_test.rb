# frozen_string_literal: true

require "test_helper"
require "dev_onboarder/requirements"
require "tmpdir"

module DevOnboarder
  class RequirementsTest < Minitest::Test
    def test_loading_a_requirements_file_lists_each_requirement_it_declares
      Dir.mktmpdir do |dir|
        path = File.join(dir, "Setupfile")
        File.write(path, <<~RUBY)
          requirement :bundle, group: :repo_setup, purpose: "Gems are installed", check: "bundle check"
          requirement :databases, group: :repo_setup, purpose: "Databases exist", check: "true"
        RUBY

        assert_equal %i[bundle databases], Requirements.load(path).map(&:key)
      end
    end
  end
end

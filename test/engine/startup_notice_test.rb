# frozen_string_literal: true

require "test_helper"
require "support/host_app"

module DevOnboarder
  class StartupNoticeTest < Minitest::Test
    def setup
      @dir = Dir.mktmpdir
    end

    def teardown
      FileUtils.remove_entry(@dir)
    end

    def test_an_app_with_a_requirement_no_run_has_recorded_gets_a_notice_when_it_starts
      File.write(File.join(@dir, "Setupfile"),
                 'requirement :databases, group: :repo_setup, purpose: "Databases exist", check: "check-db"')

      assert_equal "dev_onboarder: 1 requirement needs setup. Run bundle exec dev_onboarder.",
                   Engine.startup_notice(@dir)
    end

    def test_an_app_with_no_setup_file_gets_no_notice_when_it_starts
      assert_nil Engine.startup_notice(@dir)
    end

    def test_starting_the_server_prints_the_notice
      File.write(Rails.root.join("Setupfile"),
                 'requirement :databases, group: :repo_setup, purpose: "Databases exist", check: "check-db"')

      assert_output("dev_onboarder: 1 requirement needs setup. Run bundle exec dev_onboarder.\n") do
        Rails.application.load_server
      end
    ensure
      FileUtils.rm_f(Rails.root.join("Setupfile"))
    end
  end
end

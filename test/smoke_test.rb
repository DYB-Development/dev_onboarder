# frozen_string_literal: true

require "test_helper"
require "open3"
require "tmpdir"

class SmokeTest < Minitest::Test
  EXECUTABLE = File.expand_path("../exe/dev_onboarder", __dir__)
  LIB = File.expand_path("../lib", __dir__)
  MARKER = <<~RUBY
    requirement :marker, group: :repo_setup, purpose: "The marker file exists",
                         check: "test -f marker", fix: "touch marker"
  RUBY

  def setup
    @dir = Dir.mktmpdir
  end

  def teardown
    FileUtils.remove_entry(@dir)
  end

  def test_the_command_lists_a_requirement_its_fix_repaired_as_met
    declare MARKER

    assert_equal "met      marker — The marker file exists\n", run_command.first
  end

  def test_the_command_succeeds_in_a_repo_with_no_web_application
    declare MARKER

    assert_predicate run_command.last, :success?
  end

  def test_the_command_writes_the_setup_record_in_the_repo
    declare MARKER
    run_command

    assert_path_exists File.join(@dir, ".dev_onboarder.json")
  end

  def test_the_command_checks_a_program_declared_in_one_line
    declare %(program "ruby", version: "#{RUBY_VERSION}"\n)

    assert_equal "met      ruby — ruby #{RUBY_VERSION} or newer is installed\n", run_command.first
  end

  private

  def declare(requirements)
    File.write(File.join(@dir, "Setupfile"), requirements)
  end

  def run_command(*)
    Open3.capture2e("ruby", "-I", LIB, EXECUTABLE, *, chdir: @dir)
  end
end

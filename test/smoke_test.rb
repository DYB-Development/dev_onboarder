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

  def test_the_status_command_lists_a_requirement_no_run_has_recorded_as_new
    declare MARKER

    assert_equal "new      marker — The marker file exists\n", run_command("status").first
  end

  def test_the_features_command_lists_a_feature_no_run_has_set_up_as_not_ready
    declare <<~RUBY
      feature :payments, "Take a test payment" do
        requirement :payment_key, group: :secrets, purpose: "Payment test key is set", check: "false"
      end
    RUBY

    assert_equal "not ready  payments — Take a test payment\n", run_command("features").first
  end

  def test_the_command_lists_a_declared_variable_the_environment_holds_as_met
    declare %(env "DEV_ONBOARDER_SMOKE_KEY", from: "the vendor dashboard"\n)

    assert_equal "met      dev_onboarder_smoke_key — DEV_ONBOARDER_SMOKE_KEY is set\n",
                 run_command(environment: { "DEV_ONBOARDER_SMOKE_KEY" => "abc123" }).first
  end

  def test_the_command_reports_an_error_in_the_requirements_file_without_a_stack_trace
    declare "requirment :marker\n"

    assert_match(/\ASetupfile line 1: undefined method .requirment.[^\n]*\n\z/, run_command.first)
  end

  def test_the_command_leaves_nothing_in_a_git_repo_to_commit
    declare MARKER
    system("git", "init", "--quiet", @dir)
    system("git", "-C", @dir, "add", "Setupfile")
    system("git", "-C", @dir, "-c", "user.name=Test", "-c", "user.email=test@example.com", "commit", "--quiet", "-m",
           "Declare the marker")
    run_command

    assert_equal "?? marker\n", `git -C #{@dir} status --porcelain`
  end

  private

  def declare(requirements)
    File.write(File.join(@dir, "Setupfile"), requirements)
  end

  def run_command(*, environment: {})
    Open3.capture2e(environment, "ruby", "-I", LIB, EXECUTABLE, *, chdir: @dir)
  end
end

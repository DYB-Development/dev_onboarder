# frozen_string_literal: true

require "test_helper"
require "dev_onboarder/cli"
require "stringio"
require "tmpdir"

module DevOnboarder
  class CLITest < Minitest::Test
    NOW = Time.utc(2026, 10, 2, 14, 30)

    class ScriptedShell
      attr_reader :commands

      def initialize(passing)
        @passing = passing
        @commands = []
      end

      def succeeds?(command)
        @commands << command
        @passing.include?(command)
      end
    end

    class Keyboard
      def initialize(typed)
        @typed = typed
      end

      def tty?
        true
      end

      def noecho
        yield StringIO.new(@typed)
      end
    end

    def setup
      @dir = Dir.mktmpdir
      @out = StringIO.new
    end

    def teardown
      FileUtils.remove_entry(@dir)
    end

    def test_a_met_requirement_is_listed_as_met
      declare 'requirement :databases, group: :repo_setup, purpose: "Databases exist", check: "check-db"'
      run_cli(passing: ["check-db"])

      assert_includes @out.string, "met      databases — Databases exist"
    end

    def test_a_requirement_that_is_not_met_is_listed_as_not_met
      declare 'requirement :databases, group: :repo_setup, purpose: "Databases exist", check: "check-db"'
      run_cli

      assert_includes @out.string, "not met  databases — Databases exist"
    end

    def test_a_requirement_that_is_not_met_and_has_no_fix_shows_its_instruction
      declare 'requirement :api_key, group: :secrets, purpose: "Price key", check: "check-key", ' \
              'instruction: "Ask the team lead for the price key"'
      run_cli

      assert_includes @out.string, "         Ask the team lead for the price key"
    end

    def test_a_requirement_with_no_instruction_takes_one_line
      declare 'requirement :databases, group: :repo_setup, purpose: "Databases exist", check: "check-db"'
      run_cli

      assert_equal 1, @out.string.lines.size
    end

    def test_the_command_fails_when_a_requirement_is_still_not_met
      declare 'requirement :databases, group: :repo_setup, purpose: "Databases exist", check: "check-db"'

      assert_equal 1, run_cli
    end

    def test_the_command_succeeds_when_every_requirement_is_met
      declare 'requirement :databases, group: :repo_setup, purpose: "Databases exist", check: "check-db"'

      assert_equal 0, run_cli(passing: ["check-db"])
    end

    def test_a_second_run_shows_when_each_requirement_was_last_checked
      declare 'requirement :databases, group: :repo_setup, purpose: "Databases exist", check: "check-db"'
      run_cli(passing: ["check-db"])
      run_cli(passing: ["check-db"])

      assert_includes @out.string, "databases — Databases exist (last checked 2026-10-02 14:30 UTC)"
    end

    def test_status_runs_no_check_and_no_fix
      declare 'requirement :databases, group: :repo_setup, purpose: "Databases exist", check: "check-db"'
      run_cli(["status"])

      assert_empty @shell.commands
    end

    def test_status_lists_a_requirement_added_since_the_last_run_as_new_with_what_it_is_for
      declare 'requirement :databases, group: :repo_setup, purpose: "Databases exist", check: "check-db"'
      run_cli(["status"])

      assert_includes @out.string, "new      databases — Databases exist"
    end

    def test_status_lists_a_requirement_whose_definition_changed_as_changed
      declare 'requirement :databases, group: :repo_setup, purpose: "Databases exist", check: "check-db"'
      run_cli(passing: ["check-db"])
      declare 'requirement :databases, group: :repo_setup, purpose: "Databases exist", check: "check-all-dbs"'
      run_cli(["status"])

      assert_includes @out.string, "changed  databases — Databases exist"
    end

    def test_status_fails_when_a_requirement_is_listed
      declare 'requirement :databases, group: :repo_setup, purpose: "Databases exist", check: "check-db"'

      assert_equal 1, run_cli(["status"])
    end

    def test_status_says_nothing_has_changed_once_a_removed_requirement_is_the_only_difference
      declare <<~RUBY
        requirement :databases, group: :repo_setup, purpose: "Databases exist", check: "check-db"
        requirement :old_tool, group: :machine_tools, purpose: "The old tool is installed", check: "check-tool"
      RUBY
      run_cli(passing: %w[check-db check-tool])
      declare 'requirement :databases, group: :repo_setup, purpose: "Databases exist", check: "check-db"'
      @out.truncate(@out.rewind)
      run_cli(["status"])

      assert_equal "Nothing has changed since your last setup.\n", @out.string
    end

    PAYMENTS = <<~RUBY
      requirement :databases, group: :repo_setup, purpose: "Databases exist", check: "check-db"
      feature :payments, "Take a test payment" do
        requirement :payment_key, group: :secrets, purpose: "Payment test key is set", check: "check-key"
      end
    RUBY

    def test_the_command_succeeds_when_only_a_features_requirement_is_not_met
      declare PAYMENTS

      assert_equal 0, run_cli(passing: ["check-db"])
    end

    def test_setting_up_a_feature_lists_only_that_features_requirements
      declare PAYMENTS
      run_cli(%w[setup payments], passing: %w[check-db check-key])

      assert_equal "met      payment_key — Payment test key is set\n", @out.string
    end

    def test_setting_up_a_feature_fails_when_its_requirement_is_still_not_met
      declare PAYMENTS

      assert_equal 1, run_cli(%w[setup payments], passing: ["check-db"])
    end

    def test_setting_up_a_feature_the_repo_does_not_declare_says_so
      declare PAYMENTS
      run_cli(%w[setup paymnets])

      assert_equal "No feature named paymnets.\n", @out.string
    end

    def test_a_feature_whose_requirement_is_not_met_is_listed_as_not_ready
      declare PAYMENTS
      run_cli(["features"])

      assert_equal "not ready  payments — Take a test payment\n", @out.string
    end

    def test_a_feature_whose_requirements_are_all_met_is_listed_as_ready
      declare PAYMENTS
      run_cli(%w[setup payments], passing: ["check-key"])
      @out.truncate(@out.rewind)
      run_cli(["features"])

      assert_equal "ready      payments — Take a test payment\n", @out.string
    end

    def test_status_lists_a_features_new_requirement_under_that_feature
      declare PAYMENTS
      run_cli(["status"])

      assert_includes @out.string, "payments — Take a test payment\n  new      payment_key — Payment test key is set\n"
    end

    def test_status_succeeds_when_only_a_features_requirement_is_listed
      declare PAYMENTS
      run_cli(passing: ["check-db"])

      assert_equal 0, run_cli(["status"])
    end

    def test_the_command_succeeds_when_only_an_optional_variable_is_missing
      declare 'env "PRICE_KEY", from: "the vendor dashboard", optional: true'

      assert_equal 0, run_cli
    end

    def test_a_value_typed_for_a_missing_variable_is_stored_in_the_repos_environment_file
      declare 'env "PRICE_KEY", from: "the vendor dashboard"'
      run_cli(passing: ["git check-ignore --quiet .env"], input: Keyboard.new("abc123\n"))

      assert_equal "PRICE_KEY=abc123\n", File.read(File.join(@dir, ".env"))
    end

    def test_status_succeeds_when_only_an_optional_variable_is_listed
      declare 'env "PRICE_KEY", from: "the vendor dashboard", optional: true'

      assert_equal 0, run_cli(["status"])
    end

    private

    def declare(requirements)
      File.write(File.join(@dir, "Setupfile"), requirements)
    end

    def run_cli(argv = [], passing: [], input: StringIO.new)
      @shell = ScriptedShell.new(passing)
      CLI.new(argv, out: @out, dir: @dir, shell: @shell, clock: -> { NOW }, input: input).call
    end
  end
end

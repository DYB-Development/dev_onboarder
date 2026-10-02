# frozen_string_literal: true

require "test_helper"
require "dev_onboarder/setup"
require "tmpdir"

module DevOnboarder
  class SetupTest < Minitest::Test
    NOW = Time.utc(2026, 10, 2, 14, 30)

    class ScriptedShell
      attr_reader :commands

      def initialize(passing: [], passing_after: {})
        @passing = passing
        @passing_after = passing_after
        @commands = []
      end

      def succeeds?(command)
        @commands << command
        @passing.concat(@passing_after.fetch(command, []))
        @passing.include?(command)
      end
    end

    class RecordingSecrets
      attr_reader :asked

      def initialize
        @asked = []
      end

      def collect(requirement)
        @asked << requirement.key
      end
    end

    def setup
      @dir = Dir.mktmpdir
      @record = Record.new(File.join(@dir, ".dev_onboarder.json"))
    end

    def teardown
      FileUtils.remove_entry(@dir)
    end

    def test_a_requirement_whose_check_passes_is_met
      outcomes = run_setup([requirement(check: "check-db")], ScriptedShell.new(passing: ["check-db"]))

      assert outcomes.first.met
    end

    def test_a_requirement_whose_check_fails_is_not_met
      outcomes = run_setup([requirement(check: "check-db")], ScriptedShell.new)

      refute outcomes.first.met
    end

    def test_a_requirement_that_is_not_met_has_its_fix_run
      shell = ScriptedShell.new
      run_setup([requirement(check: "check-db", fix: "fix-db")], shell)

      assert_includes shell.commands, "fix-db"
    end

    def test_a_requirement_its_fix_repaired_is_met
      shell = ScriptedShell.new(passing_after: { "fix-db" => ["check-db"] })
      outcomes = run_setup([requirement(check: "check-db", fix: "fix-db")], shell)

      assert outcomes.first.met
    end

    def test_a_run_records_each_requirement_with_the_time_it_was_checked
      run_setup([requirement(check: "check-db")], ScriptedShell.new(passing: ["check-db"]))

      assert_equal NOW, @record.result_for(:databases).checked_at
    end

    def test_a_second_run_reports_when_each_requirement_was_last_checked
      earlier = Time.utc(2026, 10, 1, 9, 0)
      @record.save(databases: Result.new(met: true, checked_at: earlier))
      outcomes = run_setup([requirement(check: "check-db")], ScriptedShell.new(passing: ["check-db"]))

      assert_equal earlier, outcomes.first.last_checked_at
    end

    def test_a_run_records_each_requirement_with_its_fingerprint
      declared = requirement(check: "check-db")
      run_setup([declared], ScriptedShell.new(passing: ["check-db"]))

      assert_equal declared.fingerprint, @record.result_for(:databases).fingerprint
    end

    def test_a_run_that_names_a_feature_checks_only_that_features_requirements
      shell = ScriptedShell.new
      run_setup([requirement(check: "check-db"), payment_key], shell, feature: :payments)

      assert_equal ["check-key"], shell.commands
    end

    def test_a_run_that_names_no_feature_does_not_run_a_features_fix
      shell = ScriptedShell.new
      run_setup([payment_key(fix: "fix-key")], shell)

      refute_includes shell.commands, "fix-key"
    end

    def test_a_requirement_that_is_met_does_not_have_its_fix_run
      shell = ScriptedShell.new(passing: ["check-db"])
      run_setup([requirement(check: "check-db", fix: "fix-db")], shell)

      refute_includes shell.commands, "fix-db"
    end

    def test_a_run_that_names_a_feature_runs_that_features_fix
      shell = ScriptedShell.new
      run_setup([payment_key(fix: "fix-key")], shell, feature: :payments)

      assert_includes shell.commands, "fix-key"
    end

    def test_a_developer_is_asked_for_a_variable_that_is_not_set
      secrets = RecordingSecrets.new
      run_setup([requirement(check: "check-key", variable: "PRICE_KEY")], ScriptedShell.new, secrets: secrets)

      assert_equal [:databases], secrets.asked
    end

    private

    def requirement(**attributes)
      Requirement.new(key: :databases, group: :repo_setup, purpose: "Databases exist", **attributes)
    end

    def payment_key(**attributes)
      Requirement.new(key: :payment_key, group: :secrets, purpose: "Payment test key is set", feature: :payments,
                      check: "check-key", **attributes)
    end

    def run_setup(requirements, shell, feature: nil, secrets: nil)
      Setup.new(requirements: requirements, record: @record, shell: shell, clock: -> { NOW }, feature: feature,
                secrets: secrets).call
    end
  end
end

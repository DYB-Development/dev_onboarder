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

      assert_equal Result.new(met: true, checked_at: NOW), @record.result_for(:databases)
    end

    def test_a_second_run_reports_when_each_requirement_was_last_checked
      earlier = Time.utc(2026, 10, 1, 9, 0)
      @record.save(databases: Result.new(met: true, checked_at: earlier))
      outcomes = run_setup([requirement(check: "check-db")], ScriptedShell.new(passing: ["check-db"]))

      assert_equal earlier, outcomes.first.last_checked_at
    end

    private

    def requirement(**attributes)
      Requirement.new(key: :databases, group: :repo_setup, purpose: "Databases exist", **attributes)
    end

    def run_setup(requirements, shell)
      Setup.new(requirements: requirements, record: @record, shell: shell, clock: -> { NOW }).call
    end
  end
end

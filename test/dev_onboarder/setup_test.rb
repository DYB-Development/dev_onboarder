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

    private

    def requirement(**attributes)
      Requirement.new(key: :databases, group: :repo_setup, purpose: "Databases exist", **attributes)
    end

    def run_setup(requirements, shell)
      Setup.new(requirements: requirements, record: @record, shell: shell, clock: -> { NOW }).call
    end
  end
end

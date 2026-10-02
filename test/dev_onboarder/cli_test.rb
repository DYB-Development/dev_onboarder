# frozen_string_literal: true

require "test_helper"
require "dev_onboarder/cli"
require "stringio"
require "tmpdir"

module DevOnboarder
  class CLITest < Minitest::Test
    NOW = Time.utc(2026, 10, 2, 14, 30)

    class ScriptedShell
      def initialize(passing)
        @passing = passing
      end

      def succeeds?(command)
        @passing.include?(command)
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

    private

    def declare(requirements)
      File.write(File.join(@dir, "Setupfile"), requirements)
    end

    def run_cli(passing: [])
      CLI.new([], out: @out, dir: @dir, shell: ScriptedShell.new(passing), clock: -> { NOW }).call
    end
  end
end

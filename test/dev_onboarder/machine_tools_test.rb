# frozen_string_literal: true

require "test_helper"
require "dev_onboarder/requirements"
require "dev_onboarder/shell"
require "tmpdir"

module DevOnboarder
  class MachineToolsTest < Minitest::Test
    def setup
      @dir = Dir.mktmpdir
    end

    def teardown
      FileUtils.remove_entry(@dir)
    end

    def test_a_declared_program_is_a_machine_tools_requirement_named_after_it
      declared = declare('program "pg-dump"')

      assert_equal %i[pg_dump machine_tools], [declared.key, declared.group]
    end

    private

    def declare(line)
      path = File.join(@dir, "Setupfile")
      File.write(path, line)
      Requirements.load(path).first
    end

    def passes?(requirement)
      Shell.new.succeeds?(requirement.check)
    end
  end
end

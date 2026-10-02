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

    def test_a_program_that_is_not_installed_is_not_met
      refute passes?(declare('program "a-program-nobody-has-installed"'))
    end

    def test_a_program_at_its_minimum_version_is_met
      assert passes?(declare(%(program "ruby", version: "#{RUBY_VERSION}")))
    end

    def test_a_program_older_than_its_minimum_version_is_not_met
      refute passes?(declare('program "ruby", version: "99.0"'))
    end

    def test_a_program_declared_with_how_to_install_it_has_that_as_its_fix
      assert_equal "brew install libvips", declare('program "vips", install: "brew install libvips"').fix
    end

    def test_a_program_with_a_minimum_version_says_so_in_what_it_is_for
      assert_equal "psql 17 or newer is installed", declare('program "psql", version: "17"').purpose
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

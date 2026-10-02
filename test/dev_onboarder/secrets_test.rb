# frozen_string_literal: true

require "test_helper"
require "dev_onboarder/requirements"
require "dev_onboarder/shell"
require "tmpdir"

module DevOnboarder
  class SecretsTest < Minitest::Test
    VARIABLE = "DEV_ONBOARDER_TEST_KEY"

    def setup
      @dir = Dir.mktmpdir
    end

    def teardown
      FileUtils.remove_entry(@dir)
    end

    def test_a_declared_variable_the_environment_file_holds_is_met
      write ".env", "#{VARIABLE}=abc123\n"

      assert passes?(declare(%(env "#{VARIABLE}", from: "the vendor dashboard")))
    end

    def test_a_declared_variable_names_the_variable_a_developer_is_asked_for
      assert_equal VARIABLE, declare(%(env "#{VARIABLE}", from: "the vendor dashboard")).variable
    end

    def test_a_variable_declared_optional_is_an_optional_requirement
      assert declare(%(env "#{VARIABLE}", from: "the vendor dashboard", optional: true)).optional
    end

    def test_a_declared_key_file_that_exists_is_met
      write "master.key", "abc123"

      assert passes?(declare('key_file "master.key", from: "the team lead"'))
    end

    def test_a_declared_key_file_that_is_missing_is_not_met
      refute passes?(declare('key_file "master.key", from: "the team lead"'))
    end

    private

    def write(name, contents)
      File.write(File.join(@dir, name), contents)
    end

    def declare(line)
      write "Setupfile", line
      Requirements.load(File.join(@dir, "Setupfile")).first
    end

    def passes?(requirement)
      Dir.chdir(@dir) { Shell.new.succeeds?(requirement.check) }
    end
  end
end

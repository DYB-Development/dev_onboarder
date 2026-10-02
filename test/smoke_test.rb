# frozen_string_literal: true

require "test_helper"
require "open3"
require "tmpdir"

class SmokeTest < Minitest::Test
  EXECUTABLE = File.expand_path("../exe/dev_onboarder", __dir__)
  LIB = File.expand_path("../lib", __dir__)

  def test_the_command_fixes_and_records_a_requirement_in_a_repo_with_no_web_application
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "Setupfile"), <<~RUBY)
        requirement :marker, group: :repo_setup, purpose: "The marker file exists",
                             check: "test -f marker", fix: "touch marker"
      RUBY

      output, status = Open3.capture2e("ruby", "-I", LIB, EXECUTABLE, chdir: dir)

      assert_equal [true, "met      marker — The marker file exists\n", true],
                   [status.success?, output, File.exist?(File.join(dir, ".dev_onboarder.json"))]
    end
  end

  def test_the_command_checks_a_program_declared_in_one_line
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "Setupfile"), %(program "ruby", version: "#{RUBY_VERSION}"\n))

      output, = Open3.capture2e("ruby", "-I", LIB, EXECUTABLE, chdir: dir)

      assert_equal "met      ruby — ruby #{RUBY_VERSION} or newer is installed\n", output
    end
  end
end

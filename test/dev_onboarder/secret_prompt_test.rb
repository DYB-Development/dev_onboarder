# frozen_string_literal: true

require "test_helper"
require "dev_onboarder/secret_prompt"
require "dev_onboarder/requirement"
require "stringio"
require "tmpdir"

module DevOnboarder
  class SecretPromptTest < Minitest::Test
    class Keyboard
      def initialize(typed, interactive: true)
        @typed = typed
        @interactive = interactive
      end

      def tty?
        @interactive
      end

      def noecho
        yield StringIO.new(@typed)
      end
    end

    class ScriptedShell
      def initialize(succeeds)
        @succeeds = succeeds
      end

      def succeeds?(_command)
        @succeeds
      end
    end

    def setup
      @dir = Dir.mktmpdir
      @path = File.join(@dir, ".env")
      @out = StringIO.new
      @requirement = Requirement.new(key: :price_key, group: :secrets, purpose: "PRICE_KEY is set", check: "false",
                                     instruction: "Get it from the vendor dashboard.", variable: "PRICE_KEY")
    end

    def teardown
      FileUtils.remove_entry(@dir)
    end

    def test_a_value_a_developer_types_is_written_to_the_environment_file
      collect(Keyboard.new("abc123\n"))

      assert_equal "PRICE_KEY=abc123\n", File.read(@path)
    end

    def test_a_developer_is_shown_where_to_get_the_value_they_are_asked_for
      collect(Keyboard.new("abc123\n"))

      assert_includes @out.string, "PRICE_KEY — Get it from the vendor dashboard."
    end

    def test_a_developer_who_types_nothing_has_no_value_stored
      collect(Keyboard.new("\n"))

      refute_path_exists @path
    end

    private

    def collect(keyboard, ignored: true)
      SecretPrompt.new(env_file: EnvFile.new(@path), input: keyboard, out: @out,
                       shell: ScriptedShell.new(ignored)).collect(@requirement)
    end
  end
end

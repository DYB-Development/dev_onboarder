# frozen_string_literal: true

require_relative "requirements"
require_relative "setup"
require_relative "shell"

module DevOnboarder
  class CLI
    REQUIREMENTS_FILE = "Setupfile"
    RECORD_FILE = ".dev_onboarder.json"

    def initialize(argv, out: $stdout, dir: Dir.pwd, shell: Shell.new, clock: -> { Time.now })
      @argv = argv
      @out = out
      @dir = dir
      @shell = shell
      @clock = clock
    end

    def call
      outcomes.each { |outcome| @out.puts line_for(outcome) }
    end

    private

    def outcomes
      Setup.new(requirements: Requirements.load(File.join(@dir, REQUIREMENTS_FILE)),
                record: Record.new(File.join(@dir, RECORD_FILE)), shell: @shell, clock: @clock).call
    end

    def line_for(outcome)
      "#{outcome.met ? "met    " : "not met"}  #{outcome.requirement.key} — #{outcome.requirement.purpose}"
    end
  end
end

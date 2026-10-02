# frozen_string_literal: true

require_relative "requirements"
require_relative "setup"
require_relative "shell"
require_relative "status"

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
      @argv.first == "status" ? report_status : run_setup
    end

    private

    def report_status
      Status.new(requirements: requirements, record: record).call
      0
    end

    def run_setup
      outcomes = Setup.new(requirements: requirements, record: record, shell: @shell, clock: @clock).call
      outcomes.each { |outcome| @out.puts lines_for(outcome) }
      outcomes.all?(&:met) ? 0 : 1
    end

    def requirements
      Requirements.load(File.join(@dir, REQUIREMENTS_FILE))
    end

    def record
      Record.new(File.join(@dir, RECORD_FILE))
    end

    def lines_for(outcome)
      [line_for(outcome), instruction_for(outcome)].compact
    end

    def instruction_for(outcome)
      return if outcome.met || outcome.requirement.instruction.nil?

      "         #{outcome.requirement.instruction}"
    end

    def line_for(outcome)
      "#{outcome.met ? "met    " : "not met"}  #{outcome.requirement.key} — #{outcome.requirement.purpose}" \
        "#{last_checked(outcome)}"
    end

    def last_checked(outcome)
      return unless outcome.last_checked_at

      " (last checked #{outcome.last_checked_at.utc.strftime("%Y-%m-%d %H:%M UTC")})"
    end
  end
end

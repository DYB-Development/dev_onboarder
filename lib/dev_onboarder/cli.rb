# frozen_string_literal: true

require_relative "lines"
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
      return report_status if @argv.first == "status"
      return report_features if @argv.first == "features"
      return report_unknown_feature if feature && !declared_feature?

      run_setup
    end

    private

    def report_status
      @out.puts status_lines
      findings_of(nil).empty? ? 0 : 1
    end

    def status_lines
      return "Nothing has changed since your last setup." if findings.empty?

      outside_any_feature = findings_of(nil).map { |finding| Lines.for_finding(finding) }
      outside_any_feature + requirements.features.flat_map { |declared| feature_lines(declared) }
    end

    def feature_lines(declared)
      listed = findings_of(declared.name)
      return [] if listed.empty?

      ["#{declared.name} — #{declared.description}"] + listed.map { |finding| "  #{Lines.for_finding(finding)}" }
    end

    def findings_of(feature_name)
      findings.select { |finding| finding.requirement.feature == feature_name }
    end

    def report_features
      @out.puts(requirements.features.map { |declared| Lines.for_feature(declared, ready: ready?(declared)) })
      0
    end

    def ready?(declared)
      findings.none? { |finding| finding.requirement.feature == declared.name }
    end

    def report_unknown_feature
      @out.puts "No feature named #{feature}."
      1
    end

    def run_setup
      outcomes = Setup.new(requirements: requirements, record: record, shell: @shell, clock: @clock,
                           feature: feature).call
      outcomes.each { |outcome| @out.puts Lines.for_outcome(outcome) }
      outcomes.select { |outcome| required?(outcome.requirement) }.all?(&:met) ? 0 : 1
    end

    def required?(requirement)
      requirement.feature == feature && !requirement.optional
    end

    def feature
      @argv[1]&.to_sym
    end

    def declared_feature?
      requirements.features.any? { |declared| declared.name == feature }
    end

    def findings
      @findings ||= Status.new(requirements: requirements, record: record).call
    end

    def requirements
      @requirements ||= Requirements.load(File.join(@dir, REQUIREMENTS_FILE))
    end

    def record
      Record.new(File.join(@dir, RECORD_FILE))
    end
  end
end

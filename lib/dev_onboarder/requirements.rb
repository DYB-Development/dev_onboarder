# frozen_string_literal: true

require_relative "../dev_onboarder"
require_relative "machine_tools"
require_relative "requirement"
require_relative "secrets"

module DevOnboarder
  Feature = Data.define(:name, :description)

  class Requirements
    include Enumerable
    include MachineTools
    include Secrets

    attr_reader :features

    def self.load(path)
      new(File.dirname(path)).tap { |requirements| requirements.instance_eval(File.read(path), path) }
    rescue ScriptError, StandardError => e
      raise Error, "Setupfile line #{line_of(e, path)}: #{reason_of(e, path)}"
    end

    def self.line_of(error, path)
      error.backtrace_locations&.find { |location| location.path == path }&.lineno ||
        error.message[/#{Regexp.escape(path)}:(\d+)/, 1]
    end

    def self.reason_of(error, path)
      error.message.lines.first.chomp.sub(/\A#{Regexp.escape(path)}:\d+: /, "")
    end

    def initialize(dir)
      @dir = dir
      @declared = []
      @features = []
    end

    def requirement(key, **attributes)
      @declared << Requirement.new(key: key, feature: @current_feature, **attributes)
    end

    def feature(name, description)
      @features << Feature.new(name: name, description: description)
      @current_feature = name
      yield
    ensure
      @current_feature = nil
    end

    def each(&)
      @declared.each(&)
    end
  end
end

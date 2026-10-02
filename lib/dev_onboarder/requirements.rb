# frozen_string_literal: true

require_relative "machine_tools"
require_relative "requirement"

module DevOnboarder
  Feature = Data.define(:name, :description)

  class Requirements
    include Enumerable
    include MachineTools

    attr_reader :features

    def self.load(path)
      new.tap { |requirements| requirements.instance_eval(File.read(path), path) }
    end

    def initialize
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

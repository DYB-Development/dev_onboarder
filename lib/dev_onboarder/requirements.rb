# frozen_string_literal: true

require_relative "requirement"

module DevOnboarder
  class Requirements
    def self.load(path)
      new.tap { |requirements| requirements.instance_eval(File.read(path), path) }.to_a
    end

    def initialize
      @declared = []
    end

    def requirement(key, **attributes)
      @declared << Requirement.new(key: key, **attributes)
    end

    def to_a
      @declared.dup
    end
  end
end

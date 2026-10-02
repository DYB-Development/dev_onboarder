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
      @declared << Requirement.new(key: key, feature: @current_feature, **attributes)
    end

    def feature(name, _description)
      @current_feature = name
      yield
    ensure
      @current_feature = nil
    end

    def to_a
      @declared.dup
    end
  end
end

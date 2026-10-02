# frozen_string_literal: true

require_relative "requirement"
require_relative "record"

module DevOnboarder
  Outcome = Data.define(:requirement, :met)

  class Setup
    def initialize(requirements:, record:, shell:, clock:)
      @requirements = requirements
      @record = record
      @shell = shell
      @clock = clock
    end

    def call
      @requirements.map { |requirement| Outcome.new(requirement: requirement, met: true) }
    end
  end
end

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
      @requirements.map { |requirement| outcome_for(requirement) }
    end

    private

    def outcome_for(requirement)
      Outcome.new(requirement: requirement, met: met?(requirement))
    end

    def met?(requirement)
      return true if check_passes?(requirement)
      return false unless requirement.fixable?

      @shell.succeeds?(requirement.fix)
      check_passes?(requirement)
    end

    def check_passes?(requirement)
      @shell.succeeds?(requirement.check)
    end
  end
end

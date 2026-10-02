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
      outcomes = @requirements.map { |requirement| outcome_for(requirement) }
      @record.save(results_of(outcomes))
      outcomes
    end

    private

    def results_of(outcomes)
      checked_at = @clock.call
      outcomes.to_h { |outcome| [outcome.requirement.key, Result.new(met: outcome.met, checked_at: checked_at)] }
    end

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

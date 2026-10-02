# frozen_string_literal: true

require_relative "requirement"
require_relative "record"

module DevOnboarder
  Outcome = Data.define(:requirement, :met, :last_checked_at)

  class Setup
    def initialize(requirements:, record:, shell:, clock:, feature: nil, secrets: nil)
      @requirements = feature ? requirements.select { |requirement| requirement.feature == feature } : requirements
      @feature = feature
      @record = record
      @shell = shell
      @clock = clock
      @secrets = secrets
    end

    def call
      outcomes = @requirements.map { |requirement| outcome_for(requirement) }
      @record.save(results_of(outcomes))
      outcomes
    end

    private

    def results_of(outcomes)
      checked_at = @clock.call
      outcomes.to_h { |outcome| [outcome.requirement.key, result_of(outcome, checked_at)] }
    end

    def result_of(outcome, checked_at)
      Result.new(met: outcome.met, checked_at: checked_at, fingerprint: outcome.requirement.fingerprint)
    end

    def outcome_for(requirement)
      Outcome.new(requirement: requirement, met: met?(requirement),
                  last_checked_at: @record.result_for(requirement.key)&.checked_at)
    end

    def met?(requirement)
      return true if check_passes?(requirement)
      return supplied?(requirement) unless requirement.fixable? && requirement.feature == @feature

      @shell.succeeds?(requirement.fix)
      check_passes?(requirement)
    end

    def supplied?(requirement)
      @secrets.collect(requirement) if @secrets && requirement.variable
      false
    end

    def check_passes?(requirement)
      @shell.succeeds?(requirement.check)
    end
  end
end

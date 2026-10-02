# frozen_string_literal: true

require_relative "requirement"
require_relative "record"

module DevOnboarder
  Finding = Data.define(:requirement, :state)

  class Status
    def initialize(requirements:, record:)
      @requirements = requirements
      @record = record
    end

    def call
      @requirements.filter_map do |requirement|
        state = state_of(requirement)
        Finding.new(requirement: requirement, state: state) if state
      end
    end

    private

    def state_of(requirement)
      :new unless @record.result_for(requirement.key)
    end
  end
end

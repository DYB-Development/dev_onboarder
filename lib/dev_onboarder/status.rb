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
      @requirements.map { |requirement| Finding.new(requirement: requirement, state: :new) }
    end
  end
end

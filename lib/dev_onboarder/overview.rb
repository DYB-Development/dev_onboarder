# frozen_string_literal: true

require_relative "record"
require_relative "status"

module DevOnboarder
  class Overview
    Group = Data.define(:name, :rows)

    def initialize(requirements:, record:)
      @requirements = requirements
      @record = record
    end

    def groups
      @requirements.group_by(&:group).map { |name, requirements| Group.new(name: name, rows: requirements) }
    end
  end
end

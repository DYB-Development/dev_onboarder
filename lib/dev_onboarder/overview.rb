# frozen_string_literal: true

require_relative "record"
require_relative "status"

module DevOnboarder
  class Overview
    Group = Data.define(:name, :rows)
    Row = Data.define(:requirement, :state, :checked_at)
    FeatureRow = Data.define(:feature, :ready)

    def initialize(requirements:, record:)
      @requirements = requirements
      @record = record
    end

    def groups
      @requirements.group_by(&:group).map do |name, requirements|
        Group.new(name: name, rows: requirements.map { |requirement| row_for(requirement) })
      end
    end

    def features
      @requirements.features.map { |feature| FeatureRow.new(feature: feature, ready: ready?(feature)) }
    end

    def notice
      count = findings.count { |finding| finding.requirement.feature.nil? }
      return if count.zero?

      "dev_onboarder: #{count} requirement#{"s" unless count == 1} need#{"s" if count == 1} setup. " \
        "Run bundle exec dev_onboarder."
    end

    private

    def ready?(feature)
      findings.none? { |finding| finding.requirement.feature == feature.name }
    end

    def row_for(requirement)
      Row.new(requirement: requirement, state: states.fetch(requirement.key, :met),
              checked_at: @record.result_for(requirement.key)&.checked_at)
    end

    def states
      @states ||= findings.to_h { |finding| [finding.requirement.key, finding.state] }
    end

    def findings
      @findings ||= Status.new(requirements: @requirements, record: @record).call
    end
  end
end

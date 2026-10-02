# frozen_string_literal: true

module DevOnboarder
  module Lines
    STATE_LABELS = { new: "new    ", changed: "changed", not_met: "not met" }.freeze

    def self.for_outcome(outcome)
      [outcome_line(outcome), instruction(outcome)].compact
    end

    def self.for_finding(finding)
      "#{STATE_LABELS.fetch(finding.state)}  #{finding.requirement.key} — #{finding.requirement.purpose}"
    end

    def self.for_feature(feature, ready:)
      "#{ready ? "ready    " : "not ready"}  #{feature.name} — #{feature.description}"
    end

    def self.outcome_line(outcome)
      "#{outcome.met ? "met    " : "not met"}  #{outcome.requirement.key} — #{outcome.requirement.purpose}" \
        "#{last_checked(outcome)}"
    end

    def self.instruction(outcome)
      return if outcome.met || outcome.requirement.instruction.nil?

      "         #{outcome.requirement.instruction}"
    end

    def self.last_checked(outcome)
      return unless outcome.last_checked_at

      " (last checked #{outcome.last_checked_at.utc.strftime("%Y-%m-%d %H:%M UTC")})"
    end

    private_class_method :outcome_line, :instruction, :last_checked
  end
end

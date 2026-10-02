# frozen_string_literal: true

module DevOnboarder
  Requirement = Data.define(:key, :group, :purpose, :check, :fix, :instruction) do
    def initialize(key:, group:, purpose:, check:, fix: nil, instruction: nil)
      super
    end

    def fixable?
      true
    end
  end
end

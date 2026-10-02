# frozen_string_literal: true

require "digest"
require "json"

module DevOnboarder
  Requirement = Data.define(:key, :group, :purpose, :check, :fix, :instruction, :feature, :variable,
                            :optional, :timeout) do
    def initialize(key:, group:, purpose:, check:, fix: nil, instruction: nil, feature: nil, variable: nil,
                   optional: false, timeout: nil)
      super
    end

    def fixable?
      !fix.nil?
    end

    def fingerprint
      Digest::SHA256.hexdigest([check, fix, instruction].to_json)
    end
  end
end

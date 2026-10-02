# frozen_string_literal: true

require "digest"
require "json"

module DevOnboarder
  Requirement = Data.define(:key, :group, :purpose, :check, :fix, :instruction) do
    def initialize(key:, group:, purpose:, check:, fix: nil, instruction: nil)
      super
    end

    def fixable?
      !fix.nil?
    end

    def fingerprint
      Digest::SHA256.hexdigest([check, fix].to_json)
    end
  end
end

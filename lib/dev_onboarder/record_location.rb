# frozen_string_literal: true

module DevOnboarder
  module RecordLocation
    def self.path(root)
      File.join(root, ".dev_onboarder.json")
    end
  end
end

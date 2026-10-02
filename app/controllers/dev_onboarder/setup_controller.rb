# frozen_string_literal: true

module DevOnboarder
  class SetupController < DevOnboarder.base_controller.constantize
    helper KeystoneUiHelper

    def show
      @overview = Overview.new(requirements: Requirements.load(Rails.root.join("Setupfile").to_s),
                               record: Record.new(Rails.root.join(".dev_onboarder.json").to_s))
    end
  end
end

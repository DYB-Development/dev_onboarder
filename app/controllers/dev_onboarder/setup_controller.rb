# frozen_string_literal: true

module DevOnboarder
  class SetupController < DevOnboarder.base_controller.constantize
    helper KeystoneUiHelper

    rescue_from DevOnboarder::Error do |error|
      render html: helpers.ui_alert(message: error.message, type: :warning), layout: true
    end

    def show
      @overview = Engine.overview(Rails.root.to_s)
    end
  end
end

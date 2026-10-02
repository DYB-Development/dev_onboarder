# frozen_string_literal: true

module DevOnboarder
  module MachineTools
    def program(name)
      requirement name.tr("-", "_").to_sym, group: :machine_tools, purpose: "#{name} is installed", check: "true"
    end
  end
end

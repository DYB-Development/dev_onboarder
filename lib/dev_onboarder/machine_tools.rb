# frozen_string_literal: true

module DevOnboarder
  module MachineTools
    def program(name, version: nil)
      requirement name.tr("-", "_").to_sym, group: :machine_tools,
                                            purpose: "#{[name, version].compact.join(" ")} is installed",
                                            check: "command -v #{name} >/dev/null"
    end
  end
end

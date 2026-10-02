# frozen_string_literal: true

module DevOnboarder
  module Secrets
    def env(name, from:)
      requirement name.downcase.to_sym, group: :secrets, purpose: "#{name} is set",
                                        check: %(test -n "${#{name}:-}" || grep -q "^#{name}=." .env 2>/dev/null),
                                        instruction: "Get it from #{from}."
    end
  end
end

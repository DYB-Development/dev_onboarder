# frozen_string_literal: true

module DevOnboarder
  class Shell
    def succeeds?(command)
      system(command, out: File::NULL, err: File::NULL)
      true
    end
  end
end

# frozen_string_literal: true

require "open3"

module DevOnboarder
  class Shell
    Run = Data.define(:success, :output)

    def succeeds?(command)
      system(command, out: File::NULL, err: File::NULL) == true
    end

    def run(command)
      output, status = Open3.capture2e(command)
      Run.new(success: status.success?, output: output)
    end
  end
end

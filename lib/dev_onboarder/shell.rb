# frozen_string_literal: true

require "open3"

module DevOnboarder
  class Shell
    Run = Data.define(:success, :output)

    def succeeds?(command)
      system(command, out: File::NULL, err: File::NULL) == true
    end

    def run(command)
      output, = Open3.capture2e(command)
      Run.new(success: true, output: output)
    end
  end
end

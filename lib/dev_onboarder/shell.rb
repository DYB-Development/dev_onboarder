# frozen_string_literal: true

require "open3"

module DevOnboarder
  class Shell
    Run = Data.define(:success, :output)

    def succeeds?(command)
      system(command, out: File::NULL, err: File::NULL) == true
    end

    def run(command, timeout: nil)
      Open3.popen2e(command, pgroup: true) do |input, output, process|
        input.close
        printed = Thread.new { output.read }
        next Run.new(success: process.value.success?, output: printed.value) if process.join(timeout)

        Process.kill("TERM", -process.pid)
        Run.new(success: false, output: "#{printed.value}Stopped after #{timeout} seconds.\n")
      end
    end
  end
end

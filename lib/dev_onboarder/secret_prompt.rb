# frozen_string_literal: true

require "io/console"
require_relative "env_file"

module DevOnboarder
  class SecretPrompt
    def initialize(env_file:, input:, out:, shell:)
      @env_file = env_file
      @input = input
      @out = out
      @shell = shell
    end

    def collect(requirement)
      @out.puts "#{requirement.variable} — #{requirement.instruction}"
      @out.print "Value (what you type is not shown): "
      value = typed_value
      @out.puts
      @env_file.set(requirement.variable, value) unless value.empty?
    end

    private

    def typed_value
      @input.noecho(&:gets).to_s.chomp
    end
  end
end

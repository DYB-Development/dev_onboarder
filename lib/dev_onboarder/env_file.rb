# frozen_string_literal: true

module DevOnboarder
  class EnvFile
    def initialize(path)
      @path = path
    end

    def set(name, value)
      File.write(@path, "#{name}=#{value}\n")
    end
  end
end

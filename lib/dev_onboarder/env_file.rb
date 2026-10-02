# frozen_string_literal: true

module DevOnboarder
  class EnvFile
    def initialize(path)
      @path = path
    end

    def set(name, value)
      File.write(@path, values.merge(name => value).map { |key, stored| "#{key}=#{stored}\n" }.join)
    end

    def load_into(environment)
      values.each { |name, value| environment[name] ||= value }
    end

    private

    def values
      return {} unless File.exist?(@path)

      File.readlines(@path, chomp: true).to_h { |line| line.split("=", 2) }
    end
  end
end

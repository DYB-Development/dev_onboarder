# frozen_string_literal: true

require "json"

module DevOnboarder
  Result = Data.define(:met, :checked_at)

  class Record
    def initialize(path)
      @path = path
    end

    def save(results)
      File.write(@path, JSON.pretty_generate("results" => results.transform_values(&:to_h)))
    end

    def result_for(key)
      stored = JSON.parse(File.read(@path)).fetch("results")[key.to_s]
      Result.new(met: stored.fetch("met"), checked_at: stored.fetch("checked_at"))
    end
  end
end

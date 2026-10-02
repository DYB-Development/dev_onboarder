# frozen_string_literal: true

require "json"
require "time"

module DevOnboarder
  Result = Data.define(:met, :checked_at)

  class Record
    def initialize(path)
      @path = path
    end

    def save(results)
      File.write(@path, JSON.pretty_generate("results" => results.transform_values { |result| stored(result) }))
    end

    def result_for(key)
      stored = JSON.parse(File.read(@path)).fetch("results")[key.to_s]
      Result.new(met: stored.fetch("met"), checked_at: Time.iso8601(stored.fetch("checked_at")))
    end

    private

    def stored(result)
      { "met" => result.met, "checked_at" => result.checked_at.utc.iso8601 }
    end
  end
end

# frozen_string_literal: true

require "json"
require "time"

module DevOnboarder
  Result = Data.define(:met, :checked_at, :fingerprint) do
    def initialize(met:, checked_at:, fingerprint: nil)
      super
    end
  end

  class Record
    def initialize(path)
      @path = path
    end

    def save(results)
      File.write(@path, JSON.pretty_generate("results" => results.transform_values { |result| stored(result) }))
    end

    def result_for(key)
      stored = stored_results[key.to_s]
      stored && Result.new(met: stored.fetch("met"), checked_at: Time.iso8601(stored.fetch("checked_at")),
                           fingerprint: stored["fingerprint"])
    end

    private

    def stored_results
      return {} unless File.exist?(@path)

      JSON.parse(File.read(@path)).fetch("results")
    end

    def stored(result)
      { "met" => result.met, "checked_at" => result.checked_at.utc.iso8601, "fingerprint" => result.fingerprint }
    end
  end
end

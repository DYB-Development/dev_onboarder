# frozen_string_literal: true

require "test_helper"
require "dev_onboarder/overview"
require "dev_onboarder/requirements"
require "tmpdir"

module DevOnboarder
  class OverviewTest < Minitest::Test
    CHECKED_AT = Time.utc(2026, 10, 2, 14, 30)
    SETUPFILE = <<~RUBY
      requirement :databases, group: :repo_setup, purpose: "Databases exist", check: "check-db"
      requirement :seeds, group: :repo_setup, purpose: "Seed data is loaded", check: "check-seeds"
      feature :payments, "Take a test payment" do
        requirement :payment_key, group: :secrets, purpose: "Payment test key is set", check: "check-key"
      end
    RUBY

    def setup
      @dir = Dir.mktmpdir
      File.write(File.join(@dir, "Setupfile"), SETUPFILE)
      @requirements = Requirements.load(File.join(@dir, "Setupfile"))
      @record = Record.new(File.join(@dir, ".dev_onboarder.json"))
    end

    def teardown
      FileUtils.remove_entry(@dir)
    end

    def test_requirements_are_listed_under_one_entry_for_each_group
      assert_equal %i[repo_setup secrets], overview.groups.map(&:name)
    end

    private

    def overview
      Overview.new(requirements: @requirements, record: @record)
    end

    def record_met(*keys)
      results = @requirements.select { |requirement| keys.include?(requirement.key) }.to_h do |requirement|
        [requirement.key, Result.new(met: true, checked_at: CHECKED_AT, fingerprint: requirement.fingerprint)]
      end
      @record.save(results)
    end
  end
end

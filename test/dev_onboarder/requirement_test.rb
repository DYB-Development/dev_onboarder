# frozen_string_literal: true

require "test_helper"
require "dev_onboarder/requirement"

module DevOnboarder
  class RequirementTest < Minitest::Test
    def test_a_requirement_with_a_fix_command_is_fixable
      requirement = Requirement.new(key: :databases, group: :repo_setup, purpose: "Databases exist",
                                    check: "true", fix: "bin/rails db:prepare")

      assert_predicate requirement, :fixable?
    end

    def test_a_requirement_without_a_fix_command_is_not_fixable
      requirement = Requirement.new(key: :api_key, group: :secrets, purpose: "Price key",
                                    check: "false", instruction: "Ask the team lead")

      refute_predicate requirement, :fixable?
    end

    def test_a_requirement_whose_check_changes_has_a_different_fingerprint
      refute_equal fingerprint_of(check: "bin/rails db:version"), fingerprint_of(check: "bin/rails db:migrate:status")
    end

    private

    def fingerprint_of(**attributes)
      Requirement.new(key: :databases, group: :repo_setup, purpose: "Databases exist", **attributes).fingerprint
    end
  end
end

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
  end
end

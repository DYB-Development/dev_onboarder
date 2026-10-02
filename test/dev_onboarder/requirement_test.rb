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

    def test_a_requirement_whose_fix_changes_has_a_different_fingerprint
      refute_equal fingerprint_of(check: "true", fix: "bin/setup"),
                   fingerprint_of(check: "true", fix: "bin/rails db:prepare")
    end

    def test_a_requirement_whose_instruction_changes_has_a_different_fingerprint
      refute_equal fingerprint_of(check: "true", instruction: "Ask the team lead"),
                   fingerprint_of(check: "true", instruction: "Ask the vendor")
    end

    def test_a_requirement_belongs_to_no_feature_unless_it_is_given_one
      assert_nil Requirement.new(key: :databases, group: :repo_setup, purpose: "Databases exist", check: "true").feature
    end

    def test_a_requirement_holds_no_variable_unless_it_is_given_one
      assert_nil Requirement.new(key: :databases, group: :repo_setup, purpose: "Databases", check: "true").variable
    end

    def test_a_requirement_is_not_optional_unless_it_is_declared_optional
      refute Requirement.new(key: :databases, group: :repo_setup, purpose: "Databases", check: "true").optional
    end

    def test_a_requirement_has_no_time_limit_unless_it_is_given_one
      assert_nil Requirement.new(key: :databases, group: :repo_setup, purpose: "Databases", check: "true").timeout
    end

    private

    def fingerprint_of(**attributes)
      Requirement.new(key: :databases, group: :repo_setup, purpose: "Databases exist", **attributes).fingerprint
    end
  end
end

# frozen_string_literal: true

require "test_helper"
require "dev_onboarder/requirements"
require "tmpdir"

module DevOnboarder
  class RequirementsTest < Minitest::Test
    def test_loading_a_requirements_file_lists_each_requirement_it_declares
      Dir.mktmpdir do |dir|
        path = File.join(dir, "Setupfile")
        File.write(path, <<~RUBY)
          requirement :bundle, group: :repo_setup, purpose: "Gems are installed", check: "bundle check"
          requirement :databases, group: :repo_setup, purpose: "Databases exist", check: "true"
        RUBY

        assert_equal %i[bundle databases], Requirements.load(path).map(&:key)
      end
    end

    def test_a_requirement_declared_inside_a_feature_belongs_to_that_feature
      Dir.mktmpdir do |dir|
        path = File.join(dir, "Setupfile")
        File.write(path, <<~RUBY)
          feature :payments, "Take a test payment" do
            requirement :payment_key, group: :secrets, purpose: "Payment test key is set", check: "true"
          end
        RUBY

        assert_equal :payments, Requirements.load(path).first.feature
      end
    end

    def test_a_declared_feature_is_listed_with_what_it_is
      Dir.mktmpdir do |dir|
        path = File.join(dir, "Setupfile")
        File.write(path, <<~RUBY)
          feature :payments, "Take a test payment" do
            requirement :payment_key, group: :secrets, purpose: "Payment test key is set", check: "true"
          end
        RUBY

        assert_equal [Feature.new(name: :payments, description: "Take a test payment")],
                     Requirements.load(path).features
      end
    end

    def test_an_error_in_a_requirements_file_is_reported_with_the_line_it_is_on
      contents = <<~RUBY
        requirement :databases, group: :repo_setup, purpose: "Databases exist", check: "true"
        requirment :seeds, group: :repo_setup, purpose: "Seed data is loaded", check: "true"
      RUBY

      assert_match(/\ASetupfile line 2: undefined method .requirment./, error_from(contents))
    end

    def test_a_requirements_file_that_is_not_valid_ruby_is_reported_with_the_line_it_is_on
      assert_match(/\ASetupfile line 1: /, error_from("requirement :databases, group: (\n"))
    end

    def test_two_requirements_with_the_same_key_are_refused_with_the_line_of_each
      contents = <<~RUBY
        requirement :databases, group: :repo_setup, purpose: "Databases exist", check: "true"
        requirement :seeds, group: :repo_setup, purpose: "Seed data is loaded", check: "true"
        requirement :databases, group: :repo_setup, purpose: "Databases are migrated", check: "true"
      RUBY

      assert_equal "Setupfile line 3: databases is already declared on line 1", error_from(contents)
    end

    private

    def load_setupfile(contents)
      Dir.mktmpdir do |dir|
        path = File.join(dir, "Setupfile")
        File.write(path, contents)
        Requirements.load(path)
      end
    end

    def error_from(contents)
      load_setupfile(contents)
      nil
    rescue DevOnboarder::Error => e
      e.message
    end
  end
end

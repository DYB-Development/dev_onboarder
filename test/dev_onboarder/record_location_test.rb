# frozen_string_literal: true

require "test_helper"
require "dev_onboarder/record_location"
require "tmpdir"

module DevOnboarder
  class RecordLocationTest < Minitest::Test
    def setup
      @dir = File.realpath(Dir.mktmpdir)
    end

    def teardown
      FileUtils.remove_entry(@dir)
    end

    def test_a_repo_outside_git_keeps_its_setup_record_at_its_root
      assert_equal File.join(@dir, ".dev_onboarder.json"), RecordLocation.path(@dir)
    end

    def test_a_git_clone_keeps_its_setup_record_inside_its_git_directory_where_nothing_is_committed
      system("git", "init", "--quiet", @dir)

      assert_equal File.join(@dir, ".git", "dev_onboarder.json"), RecordLocation.path(@dir)
    end

    def test_each_git_worktree_keeps_its_own_setup_record
      system("git", "init", "--quiet", @dir)
      system("git", "-C", @dir, "commit", "--quiet", "--allow-empty", "-m", "first")
      worktree = File.join(@dir, "linked")
      system("git", "-C", @dir, "worktree", "add", "--quiet", worktree)

      refute_equal RecordLocation.path(@dir), RecordLocation.path(worktree)
    end
  end
end

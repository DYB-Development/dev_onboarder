# frozen_string_literal: true

require "open3"

module DevOnboarder
  module RecordLocation
    FILE = "dev_onboarder.json"

    def self.path(root)
      git_directory, status = Open3.capture2("git", "-C", root.to_s, "rev-parse", "--absolute-git-dir",
                                             err: File::NULL)
      return File.join(root, ".#{FILE}") unless status.success?

      File.join(git_directory.chomp, FILE)
    end
  end
end

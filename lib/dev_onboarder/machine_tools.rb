# frozen_string_literal: true

module DevOnboarder
  module MachineTools
    HOMEBREW_ON_PATH = "command -v brew >/dev/null"
    VERSION_CHECK = <<~'RUBY'.strip
      exit Gem::Version.new(%%x(%<name>s --version)[/\d+(\.\d+)+/].to_s) >= Gem::Version.new("%<version>s")
    RUBY

    def program(name, version: nil, install: nil)
      requirement name.tr("-", "_").to_sym, group: :machine_tools,
                                            purpose: "#{name}#{" #{version} or newer" if version} is installed",
                                            check: installed_check(name, version), fix: install
    end

    def ruby_version
      named = File.read(File.join(@dir, ".ruby-version")).strip
      requirement :ruby_version, group: :machine_tools, purpose: "Ruby #{named} is the running Ruby",
                                 check: %(test "$(ruby -e 'print RUBY_VERSION')" = "#{named}"),
                                 instruction: "This repo names Ruby #{named} and you are running Ruby #{RUBY_VERSION}."
    end

    def brewfile
      requirement :brewfile, group: :machine_tools, purpose: "Every package in the Brewfile is installed",
                             check: "#{HOMEBREW_ON_PATH} && brew bundle check --file=Brewfile --no-upgrade",
                             fix: "#{HOMEBREW_ON_PATH} && brew bundle --file=Brewfile --no-upgrade",
                             instruction: "Without Homebrew, install these yourself: #{brewfile_packages.join(", ")}."
    end

    private

    def brewfile_packages
      File.read(File.join(@dir, "Brewfile")).scan(/^\s*(?:brew|cask)\s+["']([^"']+)["']/).flatten
    end

    def installed_check(name, version)
      on_path = "command -v #{name} >/dev/null"
      return on_path unless version

      "#{on_path} && ruby -e '#{format(VERSION_CHECK, name: name, version: version)}'"
    end
  end
end

# frozen_string_literal: true

module DevOnboarder
  module MachineTools
    VERSION_CHECK = <<~'RUBY'.strip
      exit Gem::Version.new(%%x(%<name>s --version)[/\d+(\.\d+)+/].to_s) >= Gem::Version.new("%<version>s")
    RUBY

    def program(name, version: nil, install: nil)
      requirement name.tr("-", "_").to_sym, group: :machine_tools,
                                            purpose: "#{name}#{" #{version} or newer" if version} is installed",
                                            check: installed_check(name, version), fix: install
    end

    private

    def installed_check(name, version)
      on_path = "command -v #{name} >/dev/null"
      return on_path unless version

      "#{on_path} && ruby -e '#{format(VERSION_CHECK, name: name, version: version)}'"
    end
  end
end

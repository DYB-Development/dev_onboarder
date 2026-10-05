## [Unreleased]

## [0.9.1]

- The README and the install local add the gem from RubyGems.

## [0.9.0]

- The gem is a the_local provider: a host that runs `the_local install` gets info, install and develop locals for the setup tool.

## [0.8.0]

- A host adds only the gem and its `Setupfile`, and changes nothing else.
- A Rails app in development loads `.env` before its own initializers.
- The setup page is at `/dev_onboarder` in local environments with no route drawn by the app, and uses the app's `ApplicationController`.
- The setup record is kept inside the clone's git directory, one for each worktree.

## [0.7.0]

- A failed fix shows what it printed, and a requirement can set a time limit for its fix.
- An error in the `Setupfile`, a repeated key and a missing `Setupfile` are reported without a stack trace.
- A setup record that cannot be read is reported and written again.
- The setup page says so when the repo has no `Setupfile`.

## [0.6.0]

- A Rails app with keystone_ui can mount `DevOnboarder::Engine` to show the setup page.
- An app's server prints one line when it starts locally and a requirement needs setup.

## [0.5.0]

- `env` and `key_file` declare secrets and keys requirements in one line each.
- Setup asks for a missing variable's value and stores it in the repo's ignored `.env` file.
- `DevOnboarder::EnvFile#load_into` loads that file into the environment when an app starts.

## [0.4.0]

- `program`, `ruby_version` and `brewfile` declare machine tools requirements in one line each.

## [0.3.0]

- A `feature` block in the `Setupfile` groups the requirements needed only to test one feature.
- `dev_onboarder setup <feature>` checks and fixes one feature, and `dev_onboarder features` lists which are ready.
- A run now adds its results to the setup record and keeps the results it did not check.

## [0.2.0]

- `dev_onboarder status` lists each requirement that is new, changed or not met since the last run.
- The setup record stores a fingerprint of each requirement's check, fix and instruction.

## [0.1.0]

- `dev_onboarder` checks each requirement in a repo's `Setupfile`, runs its fix and records the result.

## [Unreleased]

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

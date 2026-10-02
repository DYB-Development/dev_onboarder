# dev_onboarder

One setup command that gets a developer from a fresh clone to a working repo.

## Install

Add the gem to the repo's `Gemfile` or gemspec development dependencies and run `bundle install`.

## Declare what the repo needs

Write a `Setupfile` at the repo's root. Each line declares one requirement:

```ruby
requirement :databases, group: :repo_setup, purpose: "Development and test databases exist",
                        check: "bin/rails db:version", fix: "bin/rails db:prepare"

requirement :price_key, group: :secrets, purpose: "Stock price key is set",
                        check: "test -n \"$PRICE_KEY\"", instruction: "Ask the team lead for the key"
```

- `check` is a shell command that exits zero when the requirement is met.
- `fix` is a shell command run when the check fails, after which the check runs again.
- `instruction` is shown when the requirement is still not met.

## Declare machine tools in one line

```ruby
program "psql", version: "17", install: "brew install postgresql@17"
ruby_version
brewfile
```

- `program` requires a program on the path. `version` is the oldest version accepted, read from the
  program's `--version` output, and `install` is the command run when the program is missing or too old.
- `ruby_version` requires the running Ruby to be the one the repo's `.ruby-version` names, and shows
  both versions when they differ.
- `brewfile` requires every package in the repo's `Brewfile` and installs the missing ones with
  Homebrew. Without Homebrew it installs nothing and lists the packages.

## Run it

```
bundle exec dev_onboarder
```

The command lists every requirement as met or not met, and exits with a failure status when any is
still not met. It writes what it found to `.dev_onboarder.json` in the clone, so a second run shows
when each requirement was last checked. Add that file to the repo's `.gitignore`.

## Declare what one feature needs

A requirement needed only to test one feature goes inside a `feature` block:

```ruby
feature :payments, "Take a test payment" do
  requirement :payment_key, group: :secrets, purpose: "Payment test key is set",
                            check: "test -n \"$PAYMENT_KEY\"", instruction: "Copy the test key from the payment dashboard"
end
```

- `bundle exec dev_onboarder` checks a feature's requirements, runs none of their fixes, and does not
  fail because of them.
- `bundle exec dev_onboarder setup payments` checks and fixes only that feature's requirements.
- `bundle exec dev_onboarder features` lists each feature as ready or not ready, from the record of
  the last run.

## See what changed

```
bundle exec dev_onboarder status
```

Status compares the `Setupfile` with the record of the last run and lists each requirement that is
new, changed or was left not met. It runs no check and no fix and writes nothing. It exits with a
failure status when it lists anything. A requirement counts as changed when its `check`, `fix` or
`instruction` changes.

A feature's requirements are listed under the feature's name, and status does not fail because of them.

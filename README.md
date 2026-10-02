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

## Run it

```
bundle exec dev_onboarder
```

The command lists every requirement as met or not met, and exits with a failure status when any is
still not met. It writes what it found to `.dev_onboarder.json` in the clone, so a second run shows
when each requirement was last checked. Add that file to the repo's `.gitignore`.

## See what changed

```
bundle exec dev_onboarder status
```

Status compares the `Setupfile` with the record of the last run and lists each requirement that is
new, changed or was left not met. It runs no check and no fix and writes nothing. It exits with a
failure status when it lists anything. A requirement counts as changed when its `check`, `fix` or
`instruction` changes.

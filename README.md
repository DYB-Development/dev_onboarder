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

## Declare secrets and keys in one line

```ruby
env "PRICE_KEY", from: "the vendor dashboard, under API keys"
env "MAP_KEY", from: "the team lead", optional: true
key_file "config/master.key", from: "the team lead"
```

- `env` requires an environment variable, set either in the shell or in the repo's `.env` file. When
  it is missing, setup shows where to get it and asks for the value. What is typed is not shown, and it
  is written to `.env` and to nowhere else.
- Setup stores a value only when git ignores `.env`. Otherwise it says to add `.env` to `.gitignore`.
- An `optional` variable is listed when it is missing and does not fail setup or status.
- `key_file` requires a file to exist and says who to ask for it.
- Setup asks for nothing when no keyboard is attached, as in CI.

The app reads `.env` when it starts by adding this where it boots:

```ruby
require "dev_onboarder/env_file"
DevOnboarder::EnvFile.new(".env").load_into(ENV)
```

A variable the shell already sets is left as it is.

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

## Show the setup page in a Rails app

In a Rails app that has keystone_ui, the gem adds a page that shows what the last setup run recorded:
every requirement by group with its state and when it was last checked, each feature and whether it is
ready, and the command to run. The page reads the `Setupfile` and the setup record. It runs no check and
no fix.

Mount it for local use only, in `config/routes.rb`:

```ruby
mount DevOnboarder::Engine, at: "/setup" if Rails.env.local?
```

To draw the page inside the app's own layout, name the controller it inherits from, in an initializer:

```ruby
DevOnboarder.base_controller = "ApplicationController"
```

When the app's server starts locally and a requirement outside any feature is new, changed or not met,
the server output carries one line saying how many need setup and the command to run.

A Rails app without keystone_ui gets no page, and a repo with no Rails app is unaffected. Both use the
command alone. The page is tested against keystone_ui 0.30.

## When something fails

- A fix that exits non-zero has what it printed shown under its requirement.
- A requirement can set a time limit for its fix, in seconds: `fix: "bin/rails db:prepare", timeout: 120`.
  A fix that runs past it is stopped and reported as failed.
- An error in the `Setupfile` is reported with the line it is on, and no stack trace.
- Two requirements with the same key are refused, with the line of each.
- A setup record that cannot be read is reported, and the run writes it again.
- A run writes the setup record once, when it ends, so a run stopped part way leaves the earlier record
  as it was.

## See what changed

```
bundle exec dev_onboarder status
```

Status compares the `Setupfile` with the record of the last run and lists each requirement that is
new, changed or was left not met. It runs no check and no fix and writes nothing. It exits with a
failure status when it lists anything. A requirement counts as changed when its `check`, `fix` or
`instruction` changes.

A feature's requirements are listed under the feature's name, and status does not fail because of them.

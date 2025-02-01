# Welcome Contributors! 👋
We ♥ contributors! By participating in this project, you agree to abide by the Ruby for Good [code of conduct](https://github.com/rubyforgood/skillrx?tab=coc-ov-file#readme).

If you're new here, here are some things you should know:
- This is a new project, so we are still working on files like... well, like this one
- We are launching development at [FOSDEM 2025](https://fosdem.org/2025/) on the weekend of February 1
- Application requirements [are in our wiki](https://github.com/rubyforgood/skillrx/wiki/Requirem).
- You can get a good overview of the project by [filtering the issues by the "Epic" label](https://github.com/rubyforgood/skillrx/issues?q=is%3Aissue%20state%3Aopen%20label%3AEPIC)
- Issues tagged "Help Wanted" are self-contained and great for new contributors
- Pull Requests are reviewed within a week or so
- Ensure your build passes linting and tests and addresses the issue requirements
- This project relies entirely on volunteers, so please be patient with communication

# Communication 💬
If you have any questions about an issue, comment on the issue, open a new issue, or ask in [the RubyForGood slack](https://join.slack.com/t/rubyforgood/shared_invite/zt-2k5ezv241-Ia2Iac3amxDS8CuhOr69ZA). SkillRX has a channel in the Slack which is currently labeled by an earlier name for the project: #medstick. We will be establishing office hours once the project is underway.

We are happy to answer your questions. Just ask, and someone will be there to help you!

You won't be yelled at for giving your best effort. The worst that can happen is that you'll be politely asked to change something. We appreciate any sort of contributions, and don't want a wall of rules to get in the way of that.

# Wiki Contribution Workflow
1. Follow this [SO post](https://stackoverflow.com/a/56480628/13342792) to force push the main repo's Wiki to your fork's Wiki.
2. Make edits to your fork's Wiki.
3. Create a documentation issue about your changes. Make sure to note which pages you changed and link to your fork's Wiki.
4. Someone will review and approve your changes and merge them into the main Wiki following this [SO post](https://stackoverflow.com/a/56810747/13342792)

# 🤝 Code Contribution Workflow

1. **Identify an unassigned issue**. Read more [here](#issues) about how to pick a good issue.
2. **Assign it** to avoid duplicated efforts (or request assignment by adding a comment).
3. **Fork the repo** if you're not a contributor yet. Read about becoming a contributor [here](#becoming-a-repo-contributor).
4. **Create a new branch** for the issue using the format `XXX-brief-description-of-feature`, where `XXX` is the issue number.
5. **Commit fixes locally** using descriptive messages that indicate the affected parts of the app.
6. If you create a new model run `bundle exec annotate` from the root of the app
7. **Create RSpec tests** to validate that your work fixes the issue (if you need help with this, please reach out!). Read guidelines [here](#writing-browsersystemfeature-testsspecs).
8. **Run the tests** and make sure all tests pass successfully; if any fail, fix the issues causing the failures. Read guidelines [here](#test-before-submitting-pull-requests).
9. **Final commit** if tests needed fixing.
10. **Squash smaller commits.** Read guidelines [here](#squashing-commits).
11. **Push** up the branch
12. **Create a pull request** and indicate the addressed issue (e.g. `Resolves #1`) in the title, which will ensure the issue gets closed automatically when the pull request gets merged. Read PR guidelines [here](#pull-requests).
13. **Code review**: At this point, someone will work with you on doing a code review. The automated tests will run linting, rspec, and brakeman tests. If the automated tests give :+1: to the PR merging, we can then do any additional (staging) testing as needed.

14. **Merge**: Finally if all looks good the core team will merge your code in; if your feature branch was in this main repository, the branch will be deleted after the PR is merged.

15. Deploys are currently done about once a week! Read the deployment process [here](#deployment-process).

## Issues
Please feel free to contribute! While we welcome all contributions to this app, pull-requests that address outstanding Issues *and* have appropriate test coverage for them will be strongly prioritized. In particular, addressing issues that are tagged with the next milestone should be prioritized higher.

All work is organized by issues.
[Find issues here.](https://github.com/rubyforgood/skillrx/issues)

If you would like to contribute, please ask for an issue to be assigned to you.
If you would like to contribute something that is not represented by an issue, please make an issue and assign yourself.
Only take multiple issues if they are related and you can solve all of them at the same time with the same pull request.

## Becoming a Repo Contributor

Users that are frequent contributors and are involved in discussion (join the slack channel! :)) may be given direct Contributor access to the Repo so they can submit Pull Requests directly instead of Forking first.

### Codespaces
When running tests in browser, visit the forwarded port 6080 URL to see the browser in Codespaces. You can also visit this port to access the GUI desktop in Codespaces.

In VSCode Run and Debug view, there are some helpful defaults for running RSpec tests in browser at your cursor as well as attaching to a live server. Make sure the Ruby LSP server is started before debugging.

## Squashing commits

Consider the balance of "polluting the git log with commit messages" vs. "providing useful detail about the history of changes in the git log". If you have several smaller commits that serve a one purpose, you are encouraged to squash them into a single commit. There's no hard and fast rule here about this (for now), just use your best judgement. Please don't squash other people's commits. Everyone who contributes here deserves credit for their work! :)

Only commit the schema.rb only if you have committed anything that would change the DB schema (i.e. a migration).

## Pull Requests
### Stay scoped

Try to keep your PRs limited to one particular issue, and don't make changes that are out of scope for that issue. If you notice something that needs attention but is out of scope, please [create a new issue](https://github.com/rubyforgood/human-essentials/issues/new).

### In-flight pull requests

If you are so inclined, you can open a draft PR as you continue to work on it. Sometimes we want to get a PR up there and going so that other people can review it or provide feedback, but maybe it's incomplete. This is OK, but if you do it, please tag your PR with `in-progress` label so that we know not to review / merge it.

## Tests 🧪
### Writing Browser/System/Feature Tests/Specs

Add a test for your change. If you are adding functionality or fixing a bug, you should add a test!

If you are inexperienced in writing tests or get stuck on one, please reach out for help :)

#### Guidelines
- Prefer request tests over system tests (which run much slower) unless you need to test Javascript or other interactivity
- When creating factories, in each RSpec test, hard code all values that you check with a RSpec matcher. Don't check FactoryBot default values. See [#4217](https://github.com/rubyforgood/human-essentials/issues/4217) for why.
- Keep individual tests tightly scoped, only test the endpoint that you want to test. E.g. create inventory directly using `TestInventory` rather than using an additional endpoint.
- You probably don't need to write new tests when simple re-stylings are done (ie. the page may look slightly different but the Test suite is unaffected by those changes).

### Test before submitting pull requests
Before submitting a pull request, run all tests and lints. Fix any broken tests and lints before submitting a pull request.

#### Continuous Integration
- There are Github Actions workflows which will run all tests in parallel using Knapsack and lints whenever you push a commit to your fork.
- Once your first PR has been merged, all commits pushed to an open PR will also run these workflows.

#### Local testing
- Run all lints with `bin/lint`. (You can lint a single file/folder with `bin/lint {path_to_folder_or_file}`.)
- Run all tests with `bundle exec rspec`
- You can run a single test with `bundle exec rspec {path_to_test_name}_spec.rb` or on a specific line by appending `:LineNumber`
- If you need to skip a failing test, place `pending("Reason you are skipping the test")` into the `it` block rather than skipping with `xit`. This will allow rspec to deliver the error message without causing the test suite to fail.

```ruby
  it "works!" do
    pending("Need to implement this")
    expect(my_code).to be_valid
  end
```

# overcommit-hooks

Git hooks that use [Overcommit].

## Setup

### .git-hooks Submodule

First add this repository as a [git submodule].
```bash
git submodule add -b master git@github.com:Geneious/overcommit-hooks.git .git-hooks
```

This will add this repository as a submodule at the path `.git-hooks` and set it to follow the `master` branch. 

Then to update the submodule:
``` bash
git submodule update --remote
```

You will need to rerun this to pull in new changes.

### Install overcommit

Next install [Overcommit].

```bash
gem install overcommit
```

Use [rbenv] to manage your Ruby versions.

### Install the hooks

Now install the other overcommit hooks:
```bash
overcommit --install
```

### Configure Overcommit

Add a [Overcommit configuration] file and enable the hooks that you want to use:
```bash
vim .overcommit.yml
```

## Hooks

### commit-msg

#### Jira

This hook will validate that the Jira issue number from the current branch is in the subject line of the commit message.

It can also be configured to add it automatically if it does not exist.

```yaml
CommitMsg:
  JiraIssueKey:
    enabled: true
    insert_automatically: true
    ignore:
      - '^temp/'
    magic_pattern: '^HOTFIX.*'
```

[git submodule]: https://git-scm.com/book/en/v2/Git-Tools-Submodules
[Overcommit]: https://github.com/brigade/overcommit
[Overcommit configuration]: https://github.com/brigade/overcommit#configuration
[rbenv]: https://github.com/rbenv/rbenv/

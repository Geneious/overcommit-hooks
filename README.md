# overcommit-hooks

Git hooks that use [overcommit].

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

Next install [overcommit].

```bash
gem install overcommit
```

Use [rbenv] to manage your Ruby versions.

### Install the hooks

Now install the other overcommit hooks:
```bash
overcommit --install
```

[git submodule]: https://git-scm.com/book/en/v2/Git-Tools-Submodules
[overcommit]: https://github.com/brigade/overcommit
[rbenv]: https://github.com/rbenv/rbenv/

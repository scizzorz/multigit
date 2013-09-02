# multigit

A bash function to keep track of multiple git repos and execute commands in all of them (eg `git status`)

## Usage

### Installation

Add the script to your `$PATH` or set an alias to it (it may be helpful to add this to your `.bashrc`):

```bash
$ export PATH=$PATH:/path/to/multigit.sh
```

OR

```bash
$ alias mg='/path/to/multigit.sh'
```

In order to use the included helper functions, you must source `helpers.sh` (it also may be helpful to add this to your `.bashrc`):

```bash
$ source /path/to/helpers.sh
```

### Commands

List repos:

```bash
$ mg list # tracked in ~/.multigit
$ mg -r <dir> list # found in <dir>
$ mg -r <file> list # found in <file>
```

Add/remove repos:

```bash
$ mg add|rm <repo paths> # manual
$ mg -r <dir> add|rm # found in <dir>
$ mg -r <file> add|rm # found in <file>
```

Execute `git` commands:

```bash
$ mg <command or alias> # tracked in ~/.multigit
$ mg -r <dir> <command or alias> # found in <dir>
$ mg -r <file> <command or alias> # found in <file>
```

### Remote Repositories

`multigit` supports simple remote repository tracking, although it does *not* validate them like a local repository and it does *not* support a remote `-r` flag. `multigit` expects remote repositories to be formatted with a colon separating the host from the path (<host>:<path>) and uses ssh to communicate, so any hosts defined in your `~/.ssh/config` file will work as expected. All remote repositories will be highlighted in yellow to indicate that they're remote.

```bash
$ mg add user@host:/home/user/repo
$ mg rm user@host:/home/user/repo
$ mg list user@host:/home/user/repo
```

## Dependencies

`multigit.sh` requires `git(1)`, `awk(1)`, `sponge(1)` (found in `moreutils`), `realpath(1)`

## Acknowledgements

Rudimentary bash functions courtesy of [Tyler J. Stachecki](https://github.com/tj90241). Feel free to check out his [vastly inferior copycat tool](https://github.com/tj90241/watchgit).

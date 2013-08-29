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

$ mg <command or alias> # tracked in ~/.multigit
$ mg -r <dir> <command or alias> # found in <dir>
$ mg -r <file> <command or alias> # found in <file>

## Dependencies

`multigit.sh` requires `git(1)`, `awk(1)`, `sponge(1)` (found in `moreutils`), `realpath(1)`

## Acknowledgements

Rudimentary bash functions courtesy of [Tyler J. Stachecki](https://github.com/tj90241). Feel free to check out his [vastly inferior copycat tool](https://github.com/tj90241/watchgit).

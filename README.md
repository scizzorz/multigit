# multigit

A bash function to keep track of multiple git repos and execute commands in all of them (eg `git status`)

## Installation

Source `multigit.sh` (it may be helpful to add this to your `.bashrc`):

```bash
source /path/to/multigit.sh
```

## Usage

### Commands

List repos:

```bash
$ multigit list # tracked in ~/.multigit
$ multigit -r <dir> list # found in <dir>
$ multigit -r <file> list # found in <file>
```

Add/remove repos:

```bash
$ multigit add|rm <repo paths> # manual
$ multigit -r <dir> add|rm # found in <dir>
$ multigit -r <file> add|rm # found in <file>
```

Jump to a repo:

```bash
$ multigit go <search> # looks for <search> in ~/.multigit and jumps to the location
```

Execute `git` commands:

```bash
$ multigit <command or alias> # tracked in ~/.multigit
$ multigit -r <dir> <command or alias> # found in <dir>
$ multigit -r <file> <command or alias> # found in <file>
```

### Remote Repositories

`multigit` supports simple remote repository tracking, although it does *not* validate them like a local repository and it does *not* support a remote `-r` flag. `multigit` expects remote repositories to be formatted with a colon separating the host from the path (<host>:<path>) and uses ssh to communicate, so any hosts defined in your `~/.ssh/config` file will work as expected. All remote repositories will be highlighted in yellow to indicate that they're remote.

```bash
$ multigit add user@host:/home/user/repo
$ multigit rm user@host:/home/user/repo
$ multigit list user@host:/home/user/repo
```

### Extensions

`multigit` is simple to extend: simply declare any function with a prefix `multigit-` and multigit will be able to invoke it. Recursively searching directories, reading files, and splitting arguments are automatically handled. If you want your function to read from `~/.multigit` (or any other file, for that matter) when given no arguments or `-r` flag, you can create a variable named `multigit_<extension_name>_input`.

```bash
multigit_test_input=~/.multigit
function multigit-test {
	echo "performing multigit-test on $1"
}
```

```bash
$ multigit test
performing multigit-test on /home/user/trackedRepoOne
performing multigit-test on /home/user/trackedRepoTwo
performing multigit-test on /home/user/trackedRepoThree

$ multigit test one
performing multigit-test on one

$ multigit test one two three
performing multigit-test on one
performing multigit-test on two
performing multigit-test on three

$ multigit -r ~ test
performing multigit-test on /home/user/gitRepoOne
performing multigit-test on /home/user/gitRepoTwo
performing multigit-test on /home/user/gitRepoThree
```


## Dependencies

`multigit.sh` requires `git(1)`, `awk(1)`, and `realpath(1)`

## Acknowledgements

Rudimentary bash functions courtesy of [Tyler J. Stachecki](https://github.com/tj90241). Feel free to check out his [vastly inferior copycat tool](https://github.com/tj90241/watchgit).

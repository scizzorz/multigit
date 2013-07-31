# multigit

A bash function to keep track of multiple git repos and execute commands in all of them (eg `git status`)

## Usage

### Installation
Add the script to your `$PATH` or set an alias to it (it may be helpful to add this to your `.bashrc`):

	$ export PATH=$PATH:/path/to/multigit.sh

OR

	$ alias mg='/path/to/multigit.sh'

### Commands

Add repos to `multigit`:

	$ mg add <paths>

Add recursively:

	$ mg addr <path>

Execute git commands:

	$ mg <git command or alias>

One-time (doesn't use `~/.multigit`) recursive git command:

	$ mg r <path> <git command or alias>

Remove repos:

	$ mg rm <paths>

Remove recursively:

	$ mg rmr <path>

List tracked repos:

	$ mg list

Check if a directory is a valid git repo:

	$ mg find <path>

Check recursively:

	$ mg findr <path>

## Dependencies

`multigit.sh` requires `git(1)`, `awk(1)`, `sponge(1)` (found in `moreutils`), `realpath(1)`

## Acknowledgements

Rudimentary bash functions courtesy of [Tyler J. Stachecki](https://github.com/tj90241). Feel free to check out his [vastly inferior copycat tool](https://github.com/tj90241/watchgit).

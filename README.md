# multigit

A bash function to keep track of multiple git repos and execute commands in all of them (eg `git status`)

## Usage

Source the script (it may be helpful to add this to your `.bashrc`):

	$ source multigit.sh

Add repos to `multigit`:

	$ mg add <paths>

Add recursively:

	$ mg addr <path>

Execute git commands:

	$ mg status

Remove repos:

	$ mg rm <paths>

List tracked repos:

	$ mg list

## Dependencies

`multigit.sh` requires `sponge(1)` (found in `moreutils`) and `realpath(1)`

## Acknowledgements

Rudimentary bash functions courtesy of [Tyler J. Stachecki](https://github.com/tj90241). Feel free to check out his [vastly inferior copycat tool](https://github.com/tj90241/watchgit).

# multigit

A bash function to keep track of multiple git repos and execute commands in all of them (eg `git status`)

## Usage

Source the script (it may be helpful to add this to your `.bashrc`):

	$ source multigit.sh

Add repos to `multigit`:

	$ mg add <paths>

Execute git commands:

	$ mg status


## Todo

Add `mg rm` to remove repos.

## Dependencies

`multigit.sh` requires `sponge` (found in `moreutils`) and `realpath`

#!/bin/bash
if [ -t 0 ]; then
	in=~/.multigit
else
	in=/dev/stdin
fi
this=$(realpath $0)

red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 4)
reset=$(tput sgr0)

if [ $# -eq 0 ]; then
	echo "Usage: multigit.sh <command>"
	echo "       <git command or alias>"
	echo "       list"
	echo "       add <paths>"
	echo "       rm <paths>"
	echo "       find <paths>"
	echo "       addr <path>"
	echo "       rmr <path>"
	echo "       findr <path>"
	echo "       r <path> <git command or alias>"
	exit
fi

function exists {
	[ -d "$1" ]
}
function notExists {
	[ ! -d "$1" ]
}
function warnExists {
	if notExists $1; then
		echo "${red}${1}${reset} is not a valid directory"
		true
	else
		false
	fi
}

function isGit {
	[ -d "$1/.git" ]
}
function notGit {
	[ ! -d "$1/.git" ]
}
function warnGit {
	if notGit $1; then
		echo "${red}${1}${reset} is not a git repository"
		true
	else
		false
	fi
}

case "$1" in
	list)
		cat ~/.multigit \
			| xargs $this find
	;;

	add)
		shift
		for arg in "$@"; do
			exists $arg && arg=$(realpath "${arg}")
			(warnExists $arg || warnGit $arg) && continue

			echo "adding ${green}${arg}${reset}"
			echo "${arg}" >> ~/.multigit
		done
		awk '!x[$0]++' ~/.multigit | sponge ~/.multigit
	;;

	rm)
		shift
		for arg in "$@"; do
			exists $arg && arg=$(realpath "${arg}")

			grep -v "${arg}\$" ~/.multigit | sponge ~/.multigit
			echo "removing ${red}${arg}${reset}"
		done
	;;

	find)
		shift
		for arg in "$@"; do
			exists $arg && arg=$(realpath "${arg}")

			if exists $arg && isGit $arg; then
				echo "${green}${arg}${reset}"
			else
				echo "${red}${arg}${reset}"
			fi
		done
	;;


	addr)
		shift
		warnExists $1 && exit

		find "$1" -name ".git" \
			| xargs -I {} realpath "{}/.." \
			| xargs $this add
	;;

	rmr)
		shift
		warnExists $1 && exit

		find "$1" -name ".git" \
			| xargs -I {} realpath "{}/.." \
			| xargs $this rm
	;;

	findr)
		shift
		warnExists $1 && exit

		find "$1" -name ".git" \
			| xargs -I {} realpath "{}/.." \
			| xargs $this find
	;;


	r)
		shift
		warnExists $1 && exit

		find "$1" -name ".git" \
			| xargs -I {} realpath "{}/.." \
			| $this ${*:2}
	;;

	*)
		while read -r line; do
			$this find $line
			(warnExists $line || warnGit $line) && echo && continue
			pushd "${line}" > /dev/null
			git "$@"
			popd > /dev/null
			echo
		done < $in
		true
	;;
esac

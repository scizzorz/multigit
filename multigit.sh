#!/bin/bash
if [ -t 0 ]; then
	in=~/.multigit
else
	in=/dev/stdin
fi
this=$(realpath $0)

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

function isGitRepo {
	[ -d "$1/.git" ]
}

function warnExists {
	echo "$(tput setaf 1)${1}$(tput sgr0) is not a valid directory" && false
}

function warnGit {
	echo "$(tput setaf 1)${1}$(tput sgr0) is not a git repository" && false
}

case "$1" in
	list)
		cat ~/.multigit \
			| xargs $this find
	;;

	add)
		shift
		for arg in "$@"; do
			exists $arg && \
			arg=$(realpath "${arg}") && \
			isGitRepo $arg && \
			echo "adding $(tput setaf 2)${arg}$(tput sgr0)" && \
			echo "${arg}" >> ~/.multigit
		done
		awk '!x[$0]++' ~/.multigit | sponge ~/.multigit
	;;

	rm)
		shift
		for arg in "$@"; do
			exists $arg && \
			arg=$(realpath "${arg}") && \
			grep -v "${arg}\$" ~/.multigit | sponge ~/.multigit && \
			echo "removing $(tput setaf 1)${arg}$(tput sgr0)"
		done
		true
	;;

	find)
		shift
		for arg in "$@"; do
			if [ -d "${arg}" -a -d "${arg}/.git" ]; then
				arg=$(realpath "${arg}")
				echo "$(tput setaf 2)${arg}$(tput sgr0)"
			else
				echo "$(tput setaf 1)${arg}$(tput sgr0)"
			fi
		done
	;;


	addr)
		shift
		exists $1 && \
		find "$1" -name ".git" \
			| xargs -I {} realpath "{}/.." \
			| xargs $this add
	;;

	rmr)
		shift
		exists $1 && \
		find "$1" -name ".git" \
			| xargs -I {} realpath "{}/.." \
			| xargs $this rm
	;;

	findr)
		shift
		if [ -d "${1}" ]; then
			find "$1" -name ".git" \
				| xargs -I {} realpath "{}/.." \
				| xargs $this find
		else
			echo "$(tput setaf 1)${1}$(tput sgr0) is not a valid directory"
		fi
	;;


	r)
		shift
		exists $1 && \
		find "$1" -name ".git" \
			| xargs -I {} realpath "{}/.." \
			| $this ${*:2}
	;;

	*)
		while read -r line; do
			$this find $line
			if [ -d "${line}" -a -d "${line}/.git" ]; then
				pushd "${line}" > /dev/null
				git "$@"
				popd > /dev/null
			fi
			echo
		done < $in
	;;
esac

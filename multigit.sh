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

case "$1" in
	list)
		cat ~/.multigit \
			| xargs $this find
	;;

	add)
		shift
		for arg in "$@"; do
			if [ -d "${arg}" ]; then
				arg=$(realpath "${arg}")
				if [ -d "${arg}/.git" ]; then
					echo "adding $(tput setaf 2)${arg}$(tput sgr0)"
					echo "${arg}" >> ~/.multigit
				else
					echo "$(tput setaf 1)${arg}$(tput sgr0) is not a git repository"
				fi
			else
				echo "$(tput setaf 1)${arg}$(tput sgr0) is not a valid directory"
			fi
		done
		awk '!x[$0]++' ~/.multigit | sponge ~/.multigit
	;;

	rm)
		shift
		for arg in "$@"; do
			if [ -d "${arg}" ]; then
				arg=$(realpath "${arg}")
				grep -v "${arg}\$" ~/.multigit | sponge ~/.multigit
				echo "removing $(tput setaf 1)${arg}$(tput sgr0)"
			else
				echo "$(tput setaf 1)${arg}$(tput sgr0) is not a valid directory"
			fi
		done
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
		if [ -d "${1}" ]; then
			find "$1" -name ".git" \
				| xargs -I {} realpath "{}/.." \
				| xargs $this add
		else
			echo "$(tput setaf 1)${1}$(tput sgr0) is not a valid directory"
		fi
	;;

	rmr)
		shift
		if [ -d "${1}" ]; then
			find "$1" -name ".git" \
				| xargs -I {} realpath "{}/.." \
				| xargs $this rm
		else
			echo "$(tput setaf 1)${1}$(tput sgr0) is not a valid directory"
		fi
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
		if [ -d "${1}" ]; then
			find "$1" -name ".git" \
				| xargs -I {} realpath "{}/.." \
				| $this ${*:2}
		else
			echo "$(tput setaf 1)${1}$(tput sgr0) is not a valid directory"
		fi
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

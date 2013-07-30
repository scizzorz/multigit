#!/bin/bash
if [ -t 0 ]; then
	in=~/.multigit
else
	in=/dev/stdin
fi
this=$(realpath $0)

case "$1" in
	list)
		cat ~/.multigit
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
				| $this "${*:2}"
		else
			echo "$(tput setaf 1)${1}$(tput sgr0) is not a valid directory"
		fi
	;;

	*)
		while read -r line; do
			echo "$(tput setaf 4)${line}$(tput sgr0) $@"
			pushd "${line}" > /dev/null
			git "$@"
			popd > /dev/null
			echo
		done < $in
	;;
esac

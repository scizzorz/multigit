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
			arg=$(realpath "${arg}")
			if [ -d "$arg/.git" ]; then
				echo "adding $(tput setaf 2)${arg}$(tput sgr0)"
				echo "${arg}" >> ~/.multigit
			else
				echo "failed to add $(tput setaf 1)${arg}$(tput sgr0)"
			fi
		done
		awk '!x[$0]++' ~/.multigit | sponge ~/.multigit
	;;

	rm)
		shift
		for arg in "$@"; do
			arg=$(realpath "${arg}")
			grep -v "${arg}\$" ~/.multigit | sponge ~/.multigit
			echo "removing $(tput setaf 1)${arg}$(tput sgr0)"
		done
	;;

	addr)
		shift
		find "$1" -name ".git" \
			| xargs -I {} realpath "{}/.." \
			| xargs $this add
	;;

	rmr)
		shift
		find "$1" -name ".git" \
			| xargs -I {} realpath "{}/.." \
			| xargs $this rm
	;;

	r)
		shift
		find "$1" -name ".git" \
			| xargs -I {} realpath "{}/.." \
			| $this "${*:2}"
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

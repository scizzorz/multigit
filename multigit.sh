#!/bin/bash
if [ -t 0 ]; then
	in=~/.multigit
else
	in=/dev/stdin
fi
this=$(realpath $0)

function exists {
	[ -d "$1" ] && true || (echo "$(tput setaf 1)${arg}$(tput sgr0) is not a valid directory" && false)
}

case "$1" in
	list)
		cat ~/.multigit
	;;

	add)
		shift
		for arg in "$@"; do
			exists $arg && \
			arg=$(realpath "${arg}") && \
			echo "adding $(tput setaf 2)${arg}$(tput sgr0)" && \
			echo "${arg}" >> ~/.multigit
		done && \
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

	r)
		shift
		exists $1 && \
		find "$1" -name ".git" \
			| xargs -I {} realpath "{}/.." \
			| $this ${*:2}
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

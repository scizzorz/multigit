#!/bin/bash

READ=
if [ -t 0 ]; then
	in=~/.multigit
else
	in=/dev/stdin
	READ=true
fi
this=$(realpath $0)

red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 4)
reset=$(tput sgr0)

if [ $# -eq 0 ]; then
	cat << EOF
Usage: $this [-r <list path>] <command>
	<git command or alias>
	list [<paths>]
	add <paths>
	rm <paths>

	If -r is used and <list path> is a file, multigit will read from <list path>
		instead of ~/.multigit. If <list path> is a directory, multigit will
		recursively find all git repositories instead of reading ~/.multigit.
EOF
	exit
fi

function exists {
	[ -d "$1" ]
}
function warnExists {
	if ! exists $1; then
		echo "${red}${1}${reset} is not a valid directory"
		true
	else
		false
	fi
}

function isGit {
	if [ ! -d "$1/.git" ]; then
		false
	else
		pushd "$1" > /dev/null
		git rev-parse --is-inside-work-tree &>/dev/null
		ret=$?
		popd "$1" > /dev/null
		[ $ret -eq 0 ]
	fi
}
function warnGit {
	if ! isGit $1; then
		echo "${red}${1}${reset} is not a git repository"
		true
	else
		false
	fi
}

function add {
	arg=$1
	exists $arg && arg=$(realpath "$arg")
	if [[ "$arg" == *:* ]]; then
		echo "adding ${yellow}${arg}${reset}"
		echo "$arg" >> ~/.multigit
	elif exists $arg && isGit $arg; then
		echo "adding ${green}${arg}${reset}"
		echo "$arg" >> ~/.multigit
	else
		warnExists $arg || warnGit $arg
	fi
}
function rm {
	arg=$1
	exists $arg && arg=$(realpath "$arg")

	grep -v "${arg}\$" ~/.multigit | sponge ~/.multigit
	echo "removing ${red}${arg}${reset}"
}
function list {
	arg=$1
	exists $arg && arg=$(realpath "${arg}")

	if [[ "$arg" == *:* ]]; then
		echo "${yellow}${arg}${reset}"
	elif exists $arg && isGit $arg; then
		echo "${green}${arg}${reset}"
	else
		echo "${red}${arg}${reset}"
	fi
}

case "$1" in
	-r)
		READ=true
		shift
		if [ -f $1 ]; then
			in=$1
			shift
		elif [ -d $1 ]; then
			find "$1" -name ".git" \
				| xargs -I {} realpath "{}/.." \
				| $this ${*:2}
			exit
		else
			echo "${red}${1}${reset} is not a valid path"
			exit
		fi
	;;
esac

if [ $1 == "list" ] && [ $# -eq 1 ]; then
	READ=true
fi

case "$1" in
	add|rm|list)
		cmd=$1
		shift
		if [ $READ ]; then
			while read -r line; do
				$cmd $line
			done < $in
		else
			for arg in "$@"; do
				$cmd $arg
			done
		fi
		awk '!x[$0]++' ~/.multigit | sponge ~/.multigit
	;;

	*)
		for line in $(cat $in); do
			list $line
			if [[ "$line" == *:* ]]; then # execute remotely
				# split the line
				oIFS="$IFS"
				IFS=":"
				declare -a fields=($line)
				IFS="$oIFS"
				unset oIFS

				ssh "${fields[0]}" "cd ${fields[1]} && git $@"
			else # execute locally
				(warnExists $line || warnGit $line) && echo && continue
				pushd "$line" > /dev/null
				git "$@"
				popd > /dev/null
			fi
			echo
		done
		true
	;;
esac

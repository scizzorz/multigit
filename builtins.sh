function multigit-help {
	cat << EOF
Usage: multigit [-r <list path>] <command>
	<git command or alias>
	list [<paths>]
	add <paths>
	rm <paths>
	go <search>

	If -r is used and <list path> is a file, multigit will read from <list path>
		instead of ~/.multigit. If <list path> is a directory, multigit will
		recursively find all git repositories instead of reading ~/.multigit.
EOF
}
function multigit-add {
	[ $# -eq 0 ] && return

	arg=$1
	dirExists $arg && arg=$(realpath "$arg")

	if [[ "$arg" == *:* ]]; then
		echo "adding ${multigit_yellow}${arg}${multigit_reset}"
		echo "$arg" >> ~/.multigit
	elif dirExists $arg && gitExists $arg; then
		echo "adding ${multigit_green}${arg}${multigit_reset}"
		echo "$arg" >> ~/.multigit
	else
		warnDirExists $arg || warnGitExists $arg
	fi
}

function multigit-rm {
	[ $# -eq 0 ] && return

	arg=$1
	dirExists $arg && arg=$(realpath "$arg")

	grep -v "${arg}\$" ~/.multigit | sponge ~/.multigit
	echo "removing ${multigit_red}${arg}${multigit_reset}"
}

multigit_list_input=~/.multigit
function multigit-list {
	[ $# -eq 0 ] && return

	arg=$1
	dirExists $arg && arg=$(realpath "${arg}")

	if [[ "$arg" == *:* ]]; then
		echo "${multigit_yellow}${arg}${multigit_reset}"
	elif dirExists $arg && gitExists $arg; then
		echo "${multigit_green}${arg}${multigit_reset}"
	else
		echo "${multigit_red}${arg}${multigit_reset}"
	fi
}

function multigit-go {
	[ $# -eq 0 ] && return

	search=$1
	path=$(grep "${search}" ~/.multigit)

	set -- $path

	if [ $# -eq 0 ]; then
		echo "${multigit_red}${search}${multigit_reset}: no possible directories"
	elif [ $# -gt 1 ]; then
		echo "${multigit_red}${search}${multigit_reset}: too many possible directories"
		grep "${search}" ~/.multigit
	else
		cd "${path}"
	fi
}

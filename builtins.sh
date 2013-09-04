function mg-help {
	cat << EOF
Usage: mg [-r <list path>] <command>
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
function mg-add {
	[ $# -eq 0 ] && return

	arg=$1
	dirExists $arg && arg=$(realpath "$arg")

	if [[ "$arg" == *:* ]]; then
		echo "adding ${mg_yellow}${arg}${mg_reset}"
		echo "$arg" >> ~/.multigit
	elif dirExists $arg && gitExists $arg; then
		echo "adding ${mg_green}${arg}${mg_reset}"
		echo "$arg" >> ~/.multigit
	else
		warnDirExists $arg || warnGitExists $arg
	fi
}

function mg-rm {
	[ $# -eq 0 ] && return

	arg=$1
	dirExists $arg && arg=$(realpath "$arg")

	grep -v "${arg}\$" ~/.multigit | sponge ~/.multigit
	echo "removing ${mg_red}${arg}${mg_reset}"
}

function mg-list {
	[ $# -eq 0 ] && return

	arg=$1
	dirExists $arg && arg=$(realpath "${arg}")

	if [[ "$arg" == *:* ]]; then
		echo "${mg_yellow}${arg}${mg_reset}"
	elif dirExists $arg && gitExists $arg; then
		echo "${mg_green}${arg}${mg_reset}"
	else
		echo "${mg_red}${arg}${mg_reset}"
	fi
}

function mg-go {
	[ $# -eq 0 ] && return

	search=$1
	path=$(grep "${search}" ~/.multigit)

	set -- $path

	if [ $# -eq 0 ]; then
		echo "${mg_red}${search}${mg_reset}: no possible directories"
	elif [ $# -gt 1 ]; then
		echo "${mg_red}${search}${mg_reset}: too many possible directories"
		grep "${search}" ~/.multigit
	else
		cd "${path}"
	fi
}

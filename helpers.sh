# These functions aren't included in multigit.sh because
# they modify the shell's working directory or other
# properties that can't be altered from a child process

red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 4)
reset=$(tput sgr0)

function snap {
	search=$1
	path=$(grep "${search}" ~/.multigit)

	set -- $path

	if [ $# -eq 0 ]; then
		echo "${red}multigit-snap${reset}: no possible directories"
	elif [ $# -gt 1 ]; then
		echo "${red}multigit-snap${reset}: too many possible directories"
		grep "${search}" ~/.multigit
	else
		cd "${path}"
	fi
}

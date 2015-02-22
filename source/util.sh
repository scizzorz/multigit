function dirExists {
	[ -d "$1" ]
}
function warnDirExists {
	! dirExists $1 && echo "${multigit_red}${1}${multigit_reset} is not a valid directory"
}

function gitExists {
	if [ ! -e "$1/.git" ]; then
		false
	else
		pushd "$1" > /dev/null
		git rev-parse --is-inside-work-tree &>/dev/null
		ret=$?
		popd > /dev/null
		[ $ret -eq 0 ]
	fi
}
function warnGitExists {
	! gitExists $1 && echo "${multigit_red}${1}${multigit_reset} is not a git repository"
}

function funcExists {
	t=("${(@s/ /)$(type -w $1)}")
	[ -n "${t[2]}" ] && [ "$t" '==' 'function' ]
}

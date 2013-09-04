function dirExists {
	[ -d "$1" ]
}
function warnDirExists {
	! dirExists $1 && echo "${mg_red}${1}${mg_reset} is not a valid directory"
}

function gitExists {
	if [ ! -d "$1/.git" ]; then
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
	! gitExists $1 && echo "${mg_red}${1}${mg_reset} is not a git repository"
}

function funcExists {
	t=$(type -t $1)
	[ -n "$t" ] && [ "$t" == 'function' ]
}
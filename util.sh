function dirExists {
	[ -d "$1" ]
}
function warnDirExists { # FIXME I think "! dirExists $1" can be stored and used as the return
	if ! dirExists $1; then
		echo "${mg_red}${1}${mg_reset} is not a valid directory"
		true
	else
		false
	fi
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
function warnGitExists { # FIXME I think "! gitExists $1" can be stored and used as the return
	if ! gitExists $1; then
		echo "${mg_red}${1}${mg_reset} is not a git repository"
		true
	else
		false
	fi
}

function funcExists {
	t=$(type -t $1)
	[ -n "$t" ] && [ "$t" == 'function' ]
}


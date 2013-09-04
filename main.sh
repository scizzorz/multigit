function mg {
	input=
	if [ ! -t 0 ]; then
		input=/dev/stdin
	fi

	if [ -t 1 ]; then
		mg_red=$(tput setaf 1)
		mg_green=$(tput setaf 2)
		mg_yellow=$(tput setaf 4)
		mg_reset=$(tput sgr0)
	else
		mg_red=
		mg_green=
		mg_yellow=
		mg_reset=
	fi

	if [ "$1" == '-r' ]; then
		shift
		if [ -f "$1" ]; then
			input=$1
			shift
		elif [ -d "$1" ]; then
			find "$1" -name ".git" \
				| xargs -I {} realpath "{}/.." \
				| mg ${*:2} # FIXME don't hardcode the function name?
			return
		else
			echo "${mg_red}${1}${mg_reset} is not a valid path"
			return
		fi
	fi

	# FIXME extensible! shouldn't be hardcoded.
	# commands that default to reading from
	# ~/.multigit instead of argv
	if [ "$1" == "list" ] && [ $# -eq 1 ] && [ -z $input ]; then
		input=~/.multigit
	fi

	cmd=$1
	if [ $# -eq 0 ]; then
		cmd="help"
	fi

	# mg extension exists; pass to it
	if funcExists "mg-$cmd"; then
		shift
		if [ $input ]; then
			lines=$(cat $input)
		else
			lines=$@
		fi

		# no arguments and no input
		if [ $# -eq 0 ] && [ -z $input ]; then
			mg-$cmd
		else
			for line in $lines; do
				mg-$cmd $line
			done
		fi

		temp=$(awk '!x[$0]++' ~/.multigit)
		echo "$temp" > ~/.multigit

	# no mg extension exists; pass to git
	else
		if [ -z $input ]; then
			input=~/.multigit
		fi

		lines=$(cat $input)
		for line in $lines; do
			mg-list $line

			# local
			if [[ "$line" != *:* ]]; then
				(warnDirExists $line || warnGitExists $line) && echo && continue
				pushd "$line" > /dev/null
				git "$@"
				popd > /dev/null

			# remote
			else
				# split the line
				oIFS="$IFS"
				IFS=":"
				declare -a fields=($line)
				IFS="$oIFS"
				unset oIFS

				ssh "${fields[0]}" "cd ${fields[1]} && git $@"
			fi
			echo
		done
	fi
}

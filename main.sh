function mg {
	in=
	if [ ! -t 0 ]; then
		in=/dev/stdin
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
			in=$1
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
	if [ "$1" == "list" ] && [ $# -eq 1 ] && [ -z $in ]; then
		in=~/.multigit
	fi

	cmd=$1
	if [ $# -eq 0 ]; then
		cmd="help" # FIXME doesn't actually work
	fi

	# mg extension exists; pass to it
	if funcExists "mg-$cmd"; then
		shift
		if [ $in ]; then
			lines=$(cat $in)
		else
			lines=$@
		fi

		for line in $lines; do
			mg-$cmd $line
		done

		temp=$(awk '!x[$0]++' ~/.multigit)
		echo "$temp" > ~/.multigit

	# no mg extension exists; pass to git
	else
		if [ -z $in ]; then
			in=~/.multigit
		fi

		lines=$(cat $in)
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

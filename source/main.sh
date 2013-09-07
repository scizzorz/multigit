function multigit {
	input=
	if [ ! -t 0 ]; then
		input=/dev/stdin
	fi

	if [ -t 1 ]; then
		multigit_red=$(tput setaf 1)
		multigit_green=$(tput setaf 2)
		multigit_yellow=$(tput setaf 4)
		multigit_reset=$(tput sgr0)
	else
		multigit_red=
		multigit_green=
		multigit_yellow=
		multigit_reset=
	fi

	if [ "$1" == '-r' ]; then
		shift
		if [ -f "$1" ]; then
			input=$1
			shift
		elif [ -d "$1" ]; then
			find "$1" -name .git -printf "%h\n" | $FUNCNAME ${*:2}
			return
		else
			echo "${multigit_red}${1}${multigit_reset} is not a valid path"
			return
		fi
	fi

	# show help if there's no arguments
	cmd=$1
	if [ $# -eq 0 ]; then
		cmd="help"
	fi

	# commands that have a default input
	# should read it if we don't have any
	# available for them to read
	defaultInput="multigit_${cmd}_input"
	if [ ${!defaultInput} ] && [ $# -eq 1 ] && [ -z $input ]; then
		input=${!defaultInput}
	fi


	# multigit extension exists; pass to it
	if funcExists "multigit-$cmd"; then
		shift
		if [ $input ]; then
			lines=$(cat $input)
		else
			lines=$@
		fi

		# no arguments and no input
		if [ $# -eq 0 ] && [ -z $input ]; then
			multigit-$cmd
		else
			for line in $lines; do
				multigit-$cmd $line
			done
		fi

		temp=$(awk '!x[$0]++' ~/.multigit)
		echo "$temp" > ~/.multigit

	# no multigit extension exists; pass to git
	else
		if [ -z $input ]; then
			input=~/.multigit
		fi

		lines=$(cat $input)
		for line in $lines; do
			multigit-list $line "$@"

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

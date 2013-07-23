function mg {
	if [ "$1" == "add" ]; then
		shift
		for arg in "$@"; do
			arg=$(realpath "${arg}")
			if [ -d "$arg/.git" ]; then
				echo "adding $(tput setaf 4)${arg}$(tput sgr0)"
				echo "${arg}" >> ~/.multigit
			else
				echo "failed to add $(tput setaf 4)${arg}$(tput sgr0)"
			fi
		done
		uniq ~/.multigit | sponge ~/.multigit
	else
		while read -r line; do
			echo "$(tput setaf 4)${line}$(tput sgr0) $@"
			pushd "${line}" > /dev/null
			git "$@"
			popd > /dev/null
			echo
		done < ~/.multigit
	fi
}

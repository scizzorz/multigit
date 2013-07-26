function mg {
	case "$1" in
		add)
			shift
			for arg in "$@"; do
				arg=$(realpath "${arg}")
				if [ -d "$arg/.git" ]; then
					echo "adding $(tput setaf 2)${arg}$(tput sgr0)"
					echo "${arg}" >> ~/.multigit
				else
					echo "failed to add $(tput setaf 1)${arg}$(tput sgr0)"
				fi
			done
			uniq ~/.multigit | sponge ~/.multigit
		;;

		addr)
			shift
			find "$1" -name ".git" -exec realpath {}/.. \; \
				| xargs -I {} bash -i -c "mgit add {}"
		;;

		rm)
			shift
			for arg in "$@"; do
				arg=$(realpath "${arg}")
				grep -v "${arg}" ~/.multigit | sponge ~/.multigit
				echo "removing $(tput setaf 1)${arg}$(tput sgr0)"
			done
		;;

		list)
			cat ~/.multigit
		;;

		*)
			while read -r line; do
				echo "$(tput setaf 4)${line}$(tput sgr0) $@"
				pushd "${line}" > /dev/null
				git "$@"
				popd > /dev/null
				echo
			done < ~/.multigit
		;;
	esac
}

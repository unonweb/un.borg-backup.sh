function select_borg_archive {
	# Sets: 
	# - ARCHIVE_NAME
	
	local required=(
		BORG_REPO
	)
	local archives
	local archives_array=()
	local item

	# check required
    for var in "${required[@]}"  ; do
        if [[ -z "${!var}" ]]; then
            echo "Error: ${var} is not set or is empty." >&2
			return 1
        fi
    done

	# Show available archives in the chosen repository
	echo "Checking archives at ${GREEN}${BORG_REPO}${RESET} ..."
	archives=$(borg list "${BORG_REPO}" 2>/dev/null | awk '{print $1}')

	if [ -z "${archives}" ]; then
		echo "No archives found in repository ${BORG_REPO}"
	else
		# Prompt the user to choose an archive
		echo "${BOLD}Available archives:"
		archives_array=(${archives})
		
		select item in "${archives_array[@]}"; do
			if [ -n "${item}" ]; then
				echo "Archive selected: ${item}"
				ARCHIVE_NAME="${item}"
				break # return
			else
				echo "Invalid selection. Please choose a valid archive."
			fi
		done
	fi

	if [[ -n ${ARCHIVE_NAME} ]]; then
		return 0
	else 
		return 1
	fi
}
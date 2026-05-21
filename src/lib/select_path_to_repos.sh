function select_path_to_repos {
	
	# Sets:
	# - PATH_TO_REPOS
	
	local required=(
		CFG_REPO_PATHS_ARR
	)
	local path=""
    
	# check required vars
    for var in "${required[@]}"  ; do
        if [[ -z "${!var}" ]]; then
            echo "Error: ${var} is not set or is empty." >&2
			return 1
        fi
    done

	if [[ ${#CFG_REPO_PATHS_ARR[@]} -eq 0 ]]; then
		echo "No repository paths given!"
		return 1
	fi

	# select
	echo "---"
	echo -e "${BOLD}"Select path to repositories"${RESET}"
	select path in "${CFG_REPO_PATHS_ARR[@]}"; do
		if [[ -z "${path}" ]]; then
			echo "Invalid selection, please try again."
			continue
		fi
		PATH_TO_REPOS="${path}"
		break
	done

	if [[ -n ${PATH_TO_REPOS} ]]; then
		return 0
	else 
		return 1
	fi
}
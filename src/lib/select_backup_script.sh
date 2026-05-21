function select_backup_script {
	# SETS
	# - BACKUP_SCRIPT

	source "${SCRIPT_DIR}/lib/find_best_match.sh"

	local required=(
		PATH_BACKUP_SCRIPTS
		REPO_NAME
	)

	# CHECK VARS
    for var in "${required[@]}"; do
        if [[ -z "${!var}" ]]; then
            echo "Error: ${var} is not set or empty." >&2
			return 1
        fi
    done

	local script_paths=( "${PATH_BACKUP_SCRIPTS}"/* )
	local script_names=()
	local script_name_chosen
	# another way to get the filenames:
	# ${script_paths[@]##*/}
	for path in "${script_paths[@]}"; do
		local script_name=$(basename ${path})
		script_names+=(${script_name})
	done

	# AUTOMATIC SELECTION
	local best_match=$(find_best_match "${REPO_NAME}" "${script_names[@]}")
	if [[ -n ${best_match} ]]; then
		# USER CONFIRM
		echo "${GREEN}Use this one: ${best_match}${RESET}? (Y|n)"
		read -p ">> "
		if [[ ${REPLY} == "y" || -z ${REPLY} ]]; then
			script_name_chosen="${best_match}"
		fi
	fi

	# MANUAL SELECTION
	if [[ -z ${script_name_chosen} ]]; then
		echo
		echo -e "${BOLD}Available scipts:${RESET}"
		select name in "${script_names[@]}"; do
			if [[ -z "${name}" ]]; 
				then echo "ERROR: invalid option. Try again."
			else
				script_name_chosen="${name}"
				break
			fi
		done
	fi

	# SET BACKUP_SCRIPT
	if [[ -n ${script_name_chosen} ]]; then
		BACKUP_SCRIPT="${PATH_BACKUP_SCRIPTS}/${script_name_chosen}"
	fi

	# CHECKS & RETURN
	if [[ -n ${BACKUP_SCRIPT} && -f ${BACKUP_SCRIPT} ]]; then
		return 0
	else
		if [[ ! -f ${BACKUP_SCRIPT} ]]; then
        	echo "Error: BACKUP_SCRIPT not available: ${BACKUP_SCRIPT}"
    	fi 
		return 1
	fi
}
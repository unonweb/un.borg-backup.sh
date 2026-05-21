function borg_backup {
    
	source "${SCRIPT_DIR}/lib/select_backup_script.sh"

	local required=(
		REPO_NAME
		BORG_REPO
		PATH_BACKUP_SCRIPTS
	)
    
	# CHECK VARS
    for var in "${required[@]}"  ; do
        if [[ -z "${!var}" ]]; then
            echo "Error: ${var} is not set or is empty." >&2
			return 1
        fi
    done

	if [[ ! -d ${BORG_REPO} && ! -w ${BORG_REPO} ]]; then
        echo "ERROR: Repo does not exist or is not writable by ${USER}"
        return 1
    fi
    
	# SET BACKUP_SCRIPT
   	select_backup_script
    
    # USER CONFIRM AGAIN
	echo
    df --human-readable --print-type "${BORG_REPO}"
	echo
	echo -e "BORG_REPO: ${GREEN}${BORG_REPO}${RESET}"
	echo -e "BACKUP_SCRIPT: ${GREEN}${BACKUP_SCRIPT}${RESET}"
	echo "---"
    while true; do
        echo "Hit enter to perform backup!"
        read -p ">> "
        echo ""
        if [[ -z ${REPLY} ]]; then
            break
        fi
    done

    # PERFORM BACKUP
    ${BACKUP_SCRIPT}

	local exit_code=${?}

	return ${exit_code}
}
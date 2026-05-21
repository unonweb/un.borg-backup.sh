function borg_prune {

	local required=(
		BORG_REPO
		CFG_KEEP_DAILY
		CFG_KEEP_WEEKLY
		CFG_KEEP_MONTHLY
	)

	# check required vars
    for var in "${required[@]}"; do
        if [[ -z "${!var}" ]]; then
            echo "Error: ${var} is not set or empty."
			return 1
        fi
    done

	echo "---"
	echo -e "--keep-daily ${GREEN}${CFG_KEEP_DAILY}${RESET}"
	echo -e "--keep-weekly ${GREEN}${CFG_KEEP_WEEKLY}${RESET}"
	echo -e "--keep-monthly ${GREEN}${CFG_KEEP_MONTHLY}${RESET}"
	
	# change defaults
	echo -e "${BOLD}Change these defaults?${RESET} (y|n)"
	read -p ">> "
	
	if [[ ${REPLY} == "y" ]]; then
		echo -n "--keep-daily "; read CFG_KEEP_DAILY
		echo -n "--keep-weekly "; read CFG_KEEP_WEEKLY
		echo -n "--keep-monthly "; read CFG_KEEP_MONTHLY
	fi
	
	# prune
	echo -e "${BOLD}Pruning repository ${GREEN}${BORG_REPO}${RESET} ..."
	borg prune \
		--list \
		--show-rc \
		--keep-daily ${CFG_KEEP_DAILY} \
		--keep-weekly ${CFG_KEEP_WEEKLY} \
		--keep-monthly ${CFG_KEEP_MONTHLY} \
		"${BORG_REPO}"
	
	local exit_code=${?}

	return ${exit_code}
}
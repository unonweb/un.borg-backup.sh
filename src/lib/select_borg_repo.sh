function select_borg_repo() {
	# SETS:
	# - BORG_REPO
	# - REPO_NAME

	local repos_array=()
	local repo # for select
	local required=(
		PATH_TO_REPOS
	)
    
	# check required vars
    for var in "${required[@]}"  ; do
        if [[ -z "${!var}" ]]; then
            echo "Error: ${var} is not set or is empty." >&2
			return 1
        fi
    done

	# set repos_array
	## only repos owned by current user are returned

	echo "---"
	echo "Searching for repos in ${PATH_TO_REPOS} ..."
	#find $PATH_TO_REPOS -maxdepth 1 -mindepth 1 -type d -user $USER -print0 -exec basename {} \; |
	#  while IFS= read -r -d '' item; do
	#    repos_array+=($item)
	#  done

	mapfile -t repos_array < <(find ${PATH_TO_REPOS} -maxdepth 1 -mindepth 1 -type d -user ${USER} -exec basename {} \;) # find /media/frida/borg_backup -maxdepth 1 -mindepth 1 -type d -exec basename {} \;
	echo "Number of repos  for ${USER}: ${#repos_array[@]}"
	echo "---"

	# check
	if [[ ${#repos_array[@]} -eq 0 ]]; then
		echo "Error: repos_array is empty."
		return 1
	fi

	# select
	echo -e "${BOLD}Select repository in ${GREEN}${PATH_TO_REPOS}${RESET}"
	select repo in "${repos_array[@]}"; do

		if [[ -z "${repo}" ]]; then
			echo "Invalid selection, please try again."
			continue
		fi

		BORG_REPO="${PATH_TO_REPOS}/${repo}"
		REPO_NAME="${repo}"

		break
	done

	if [[ -n ${BORG_REPO} && -n ${BORG_REPO} ]]; then
		return 0
	else 
		return 1
	fi
}
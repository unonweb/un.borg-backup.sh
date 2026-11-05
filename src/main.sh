#!/bin/bash

# script location
export SCRIPT_PATH="$(readlink -f "${BASH_SOURCE}")"
export SCRIPT_DIR=$(dirname -- "$(readlink -f "${BASH_SOURCE}")")
export SCRIPT_NAME=$(basename -- "$(readlink -f "${BASH_SOURCE}")")
export SCRIPT_PARENT=$(dirname "${SCRIPT_DIR}")

# formatting
export ESC=$(printf "\e")
export BOLD="${ESC}[1m"
export RESET="${ESC}[0m"
export RED="${ESC}[31m"
export GREEN="${ESC}[32m"
export BLUE="${ESC}[34m"
export UNDERLINE="${ESC}[4m"
export CYAN="\e[36m"

PATH_CONFIG="${SCRIPT_PARENT}/config.cfg"
PATH_DEFAULTS="${SCRIPT_PARENT}/defaults.cfg"
PATH_BACKUP_SCRIPTS="${SCRIPT_DIR}/run"

# globals dynamic
BORG_REPO="" # path of selected repo
REPO_NAME="" # name of selected repo
PATH_TO_REPOS="" # path to all repos
CFG_REPO_PATHS_ARR=()
ARCHIVE_NAME=""
BACKUP_SCRIPT=""

# IMPORTS
source "${SCRIPT_DIR}/lib/borg_prune.sh"
source "${SCRIPT_DIR}/lib/borg_backup.sh"
source "${SCRIPT_DIR}/lib/read_file_to_map.sh"
source "${SCRIPT_DIR}/lib/select_borg_archive.sh"
source "${SCRIPT_DIR}/lib/select_borg_repo.sh"
source "${SCRIPT_DIR}/lib/select_path_to_repos.sh"
source "${SCRIPT_DIR}/lib/borg_mount_archive.sh"

function main {

    # local
	local options_1=(
		"Select existing repo"
		"Init new repo"
		"Edit config"
	)
    local options_2=(
        "Backup"
        "List archives"
        "Prune"
        "Compact"
        "Mount"
		"Delete"
		"Info"
		"Change repo"
    )

	# CONFIG & DEFAULTS
	if [[ -r ${PATH_CONFIG} ]]; then
		source "${PATH_CONFIG}"
	else
		echo "<4>WARN: No config file found at ${PATH_CONFIG}. Using defaults ..."
		source "${PATH_DEFAULTS}"
	fi
	
	# MENU: INIT OR SELECT EXISTING
	select opt in "${options_1[@]}"; do
		if [[ -z "${opt}" ]]; then 
			echo "ERROR: invalid option. Try again."
			continue
		fi 
		
		case ${opt} in

			"Init new repo")
				# set PATH_TO_REPOS
				select_path_to_repos || { echo "Error: Failed to set PATH_TO_REPOS"; continue; }
				# set REPO_NAME
				echo "Enter name for new repo at ${GREEN}${PATH_TO_REPOS}${RESET}"
				read -p ">> " REPO_NAME
				
				BORG_REPO="${PATH_TO_REPOS}/${REPO_NAME}"

				# check
				if [[ ! -w ${PATH_TO_REPOS} ]]; then
					echo "ERROR: ${PATH_TO_REPOS} is not writable by ${USER}"
					exit 1
				fi
				
				# confirm
				echo -e "Init new repo at ${GREEN}${BORG_REPO}${RESET}? (y|n)"
				read -p ">> "
				echo ""
				if [[ ${REPLY} == "y" ]]; then
					# init repo
					borg init --encryption=repokey ${BORG_REPO} # init local repo
					break
				else
					echo "Aborted by user."
					continue
				fi
				;;

			"Select existing repo")
				# set PATH_TO_REPOS
				select_path_to_repos || { echo "Error: Failed to set PATH_TO_REPOS"; continue; }
				# set BORG_REPO
				# set REPO_NAME
				select_borg_repo || { echo "Error: Failed to set BORG_REPO"; continue; }
				# set passphrase
				#echo -e "${BOLD}Enter passphrase for ${GREEN}${BORG_REPO}${RESET}"
				#read -sp ">> " BORG_PASSPHRASE
				#echo
				break
				;;
			
			"Edit config")
				echo
				nano "${PATH_CONFIG}"
				continue
				;;
		esac
	done

    export BORG_REPO
    export BORG_PASSPHRASE

	# MENU: WHAT TO DO WITH REPO?
    # now we have a repository
    # interactive loop
    while true; do
        # header
        echo "---"
		echo -e "${BOLD}What do you want to do with ${GREEN}${REPO_NAME}${RESET}?"
        # select
        select opt in "${options_2[@]}"; do
            if [[ -z "${opt}" ]]; then
                echo "ERROR: invalid option. Try again."
            else
                break
            fi
        done

        case ${opt} in

			"Backup")
				borg_backup
				;;

			"List archives")
				echo -e "Listing archives in ${BORG_REPO} ..."
				echo -en "${GREEN}"
				borg list ${BORG_REPO}
				echo -en "${RESET}"
				;;

			"Prune")
				borg_prune
				;;

			"Compact")
				# actually free repo disk space by compacting segments
				echo -e "${BOLD}Compacting ${GREEN}${BORG_REPO}${RESET} ..."
				borg compact "${BORG_REPO}"
				;;

			"Mount")
				# Set ARCHIVE_NAME
				select_borg_archive || { echo "Error: Failed to set ARCHIVE_NAME"; continue; }
				borg_mount_archive
				#export ARCHIVE_NAME BORG_REPO CFG_MOUNT_POINT \
				#"${SCRIPT_DIR}/run/borg.mount-archive.sh"
				;;
			
			"Delete")
				#select_borg_archive
				echo -e "${BOLD}Enter archive to delete${RESET}"
				read -p ">> "
				if [[ -n ${REPLY} ]]; then
					ARCHIVE_NAME=${REPLY}
					borg delete --list --stats --progress ${BORG_REPO}::${ARCHIVE_NAME}
					echo "When deleting archives, repository disk space is not freed until you run borg compact."
				else
					echo "Error: Empty REPLY"
				fi
				;;

			"Change repo")
				select_borg_repo
				;;

			"Info")
				echo "---"
				borg info "${BORG_REPO}"
				;;

			*)
				echo "Invalid selection: ${opt}"
				sleep 1
				;;

        esac
    done
}

main

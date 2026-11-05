# REQUIRES
# --------
# - BORG_REPO

function borg_backup_home {
	
	local path_backup="/home/${USER}"

	echo "Starting to backup ${GREEN}${path_backup}${RESET} ..."

	borg create "${BORG_REPO}"::'{hostname}-{now}' ${path_backup} \
		--progress \
		--verbose \
		--filter AME \
		--list \
		--stats \
		--lock-wait 600 \
		--compression lz4 \
		--exclude-caches \
		--exclude "${path_backup}/.cache" \
		--exclude "${path_backup}/.npm/_logs" \
		--exclude "${path_backup}/.npm/_cacache" \
		--exclude "${path_backup}/.config/Code/Cache" \
		--exclude "${path_backup}/.config/Code/CachedData" \
		--exclude "${path_backup}/.config/Code/Service Worker/ScriptCache" \
		--exclude "${path_backup}/.config/Code/User/History" \
		--exclude "${path_backup}/.config/libreoffice/*/cache" \
		--exclude "${path_backup}/.local/share/Trash" \

	#2>> ${SCRIPT_NAME}.log
	EXIT_CODE_BACKUP=$?
}

borg_backup_home ${@}
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
		--exclude ".cache" \
		--exclude ".npm/_logs" \
		--exclude ".npm/_cacache" \
		--exclude ".config/Code/Cache" \
		--exclude ".config/Code/CachedData" \
		--exclude ".config/Code/Service Worker/ScriptCache" \
		--exclude ".config/Code/User/History" \
		--exclude ".config/libreoffice/*/cache" \
		--exclude ".local/share/Trash" \

	#2>> ${SCRIPT_NAME}.log
	EXIT_CODE_BACKUP=$?
}

borg_backup_home ${@}
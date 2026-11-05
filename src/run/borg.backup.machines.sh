# REQUIRES
# --------
# - BORG_REPO

function borg_backup_machines {

	local path_backup
	local repo_name

	repo_name=${BORG_REPO##*/} # /media/frida/borg_backup/machines.ghost-ub --> machines.ghost-ub
	repo_name=${repo_name//./\/} # machines.ghost-ub --> machines/ghost-ub
	
	path_backup="/var/lib/${repo_name}" # --> /var/lib/machines/ghost-ub
	
	echo "Starting to backup ${path_backup}"

	sudo borg create "${BORG_REPO}"::'{hostname}-{now}' ${path_backup} \
		--progress \
		--verbose \
		--filter AME \
		--list \
		--stats \
		--lock-wait 600 \
		--compression lz4 \
		--exclude-caches \
		--exclude '.Trash-1000' \
		--exclude "dev" \
		--exclude "mnt" \
		--exclude "proc" \
		--exclude "run" \
		--exclude "sys" \
		--exclude "tmp" \
		--exclude "var/tmp" \
		--exclude "var/run" \
		--exclude "var/cache" \
		--exclude "var/lock"
		

	EXIT_CODE_BACKUP=${?}
}

borg_backup_machines ${@}
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
		--exclude "${path_backup}/dev" \
		--exclude "${path_backup}/mnt" \
		--exclude "${path_backup}/proc" \
		--exclude "${path_backup}/run" \
		--exclude "${path_backup}/sys" \
		--exclude "${path_backup}/tmp" \
		--exclude "${path_backup}/var/tmp" \
		--exclude "${path_backup}/var/run" \
		--exclude "${path_backup}/var/cache" \
		--exclude "${path_backup}/var/lock"
		

	EXIT_CODE_BACKUP=${?}
}

borg_backup_machines ${@}
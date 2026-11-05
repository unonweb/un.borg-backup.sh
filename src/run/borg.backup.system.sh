function borg_backup_system {

	local path_backup="/etc /root /var /opt"

	echo "Starting to backup ${path_backup}"

	sudo --set-home --preserve-env borg create ${BORG_REPO}::'{hostname}-{now}' "${path_backup}" \
		--progress \
		--verbose \
		--filter AME \
		--list \
		--stats \
		--lock-wait 600 \
		--compression lz4 \
		--exclude-caches \
		--exclude 'var/tmp' \
		--exclude 'var/run' \
		--exclude 'var/cache' \
		--exclude 'var/lock'
	#2>> borg.log
	#2> >(tee borg.log >&2)

	EXIT_CODE_BACKUP=${?}
}

borg_backup_system ${@}
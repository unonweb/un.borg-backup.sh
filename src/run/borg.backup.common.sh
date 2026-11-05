# REQUIRES
# --------
# - BORG_REPO

function borg_backup_common {

	local path_backup="/media/common"

	echo "Starting to backup ${path_backup}"

	borg create "${BORG_REPO}"::'{hostname}-{now}' ${path_backup} \
		--progress \
		--verbose \
		--filter AME \
		--list \
		--stats \
		--lock-wait 600 \
		--compression lz4 \
		--exclude-caches \
		--exclude '**/.Trash-1000' \
		--exclude 'software/linux/os' \
		--exclude 'software/win/os' \
		--exclude '**/mkosi.output' \
		--exclude '**/mkosi.cache' \
		--exclude '**/.parcel-cache' \
		--exclude '**/node_modules'

	EXIT_CODE_BACKUP=${?}
}

borg_backup_common ${@}
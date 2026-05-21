function borg_mount_archive {
    
	local mount_cmd
	local required=(
		BORG_REPO
		ARCHIVE_NAME
		CFG_MOUNT_POINT
	)
    
	# CHECK VARS
    for var in "${required[@]}"  ; do
        if [[ -z "${!var}" ]]; then
            echo "Error: ${var} is not set or is empty." >&2
			return 1
        fi
    done

    # Create mount point if it doesn't exist
    if [ ! -d "${CFG_MOUNT_POINT}" ]; then
        echo -e "Creating mountpoint: ${GREEN}${CFG_MOUNT_POINT}${RESET}"
        mkdir -p "${CFG_MOUNT_POINT}"
    fi

    # Mount the chosen archive
    mount_cmd="borg mount ${BORG_REPO}::${ARCHIVE_NAME} ${CFG_MOUNT_POINT} -o allow_other"
    echo "Mounting archive with cmd:"
    echo -e "${mount_cmd}"
    ${mount_cmd}

    if [ ${?} -eq 0 ]; then
        echo "Archive mounted successfully at ${GREEN}${CFG_MOUNT_POINT}${RESET}"
        echo "When you finish don't forget to unmount with:"
        echo "umount ${CFG_MOUNT_POINT}"
		return 0
    else
        echo "Error: Failed to mount the archive."
		return 1
    fi
}
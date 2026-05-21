function read_file_to_map { # _result ${file_path}

	local -n _result=${1}
	local file_path=${2}
	local ignore_comments=true
	local feedback=0

	if [[ ! -e "${file_path}" ]]; then
		echo -e "${RED}[read_file_to_map] ERROR: File not found: ${file_path}${RESET}"
		return 1
	else
		if ((feedback)); then
			echo "Reading ${file_path} ..." 
		fi
  	fi

	# Read the file line by line
	while IFS='=' read -r key value; do
		# if line starts with # ignore it
		if [[ ${ignore_comments} == true ]] && [[ "${key}" == \#* ]]; then
        	continue
		fi
		# Trim leading and trailing whitespace from key and value
		key="${key#"${key%%[![:space:]]*}"}"  # Trim leading whitespace
		key="${key%"${key##*[![:space:]]}"}"  # Trim trailing whitespace
		value="${value#"${value%%[![:space:]]*}"}"  # Trim leading whitespace
		value="${value%"${value##*[![:space:]]}"}"  # Trim trailing whitespace

		# Store the key-value pair in the associative array
		if ((feedback)); then
			echo "${key}=${value}"
		fi
		_result["${key}"]="${value}"
	done <"${file_path}"
}
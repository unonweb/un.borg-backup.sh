find_best_match() {
    local target="${1}"
    shift
    local files=("${@}")

    # Ensure associative arrays are supported (Bash 4.0+)
    declare -A target_words
    local word

    # Clean the target name by replacing dots and dashes with spaces
    local clean_target
    clean_target=$(echo "${target}" | tr '.-' ' ')

    # Store target words in an associative array for O(1) lookups
    for word in ${clean_target}; do
        target_words["${word}"]=1
    done

    local best_match=""
    local max_matches=0

    local file
    for file in "${files[@]}"; do
        # Clean the current filename the same way
        local clean_file
        clean_file=$(echo "${file}" | tr '.-' ' ')
        
        local match_count=0
        for word in ${clean_file}; do
            if [[ -n "${target_words[${word}]}" ]]; then
                ((match_count++))
            fi
        done

        # If this file has more matches than our previous best, update it.
        # Using '>' ensures that in case of a tie, the first match is kept.
        if (( match_count > max_matches )); then
            max_matches=${match_count}
            best_match="${file}"
        fi
    done

    # Output the winner (or nothing if 0 words matched)
    echo "${best_match}"
}
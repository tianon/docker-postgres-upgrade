#!/bin/bash
set -e

# TODO scrape this somehow
supportedVersions=(
	9.1
	9.2
	9.3
	9.4
	9.5
	9.6
)

for i in "${!supportedVersions[@]}"; do
	old="${supportedVersions[$i]}"
	(( j = i + 1 ))
	for new in "${supportedVersions[@]:$j}"; do
		dir="$old-to-$new"
		echo "$old -> $new ($dir)"
		mkdir -p "$dir"
		sed \
			-e "s!%%POSTGRES_OLD%%!$old!g" \
			-e "s!%%POSTGRES_NEW%%!$new!g" \
			Dockerfile.template \
			> "$dir/Dockerfile"
	done
done

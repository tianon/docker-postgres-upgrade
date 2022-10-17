#!/usr/bin/env bash
set -Eeuo pipefail

# TODO scrape this somehow?
supportedVersions=(
	15
	14
	13
	12
	11
	10
	9.6
	#9.5
	#9.4
	#9.3
	#9.2
)
suite='bullseye'

for i in "${!supportedVersions[@]}"; do
	new="${supportedVersions[$i]}"
	echo "# $new"
	docker pull "postgres:$new-$suite" > /dev/null
	(( j = i + 1 ))
	for old in "${supportedVersions[@]:$j}"; do
		dir="$old-to-$new"
		echo "- $old -> $new ($dir)"
		oldVersion="$(
			docker run --rm -e OLD="$old" "postgres:$new-$suite" bash -Eeuo pipefail -c '
				sed -i "s/\$/ $OLD/" /etc/apt/sources.list.d/pgdg.list
				apt-get update -qq 2>/dev/null
				apt-cache policy "postgresql-$OLD" \
					| awk "\$1 == \"Candidate:\" { print \$2; exit }"
			'
		)"
		echo "  - $oldVersion"
		if [ "$oldVersion" = '(none)' ]; then
			continue
		fi
		mkdir -p "$dir"
		sed \
			-e "s!%%POSTGRES_OLD%%!$old!g" \
			-e "s!%%POSTGRES_OLD_VERSION%%!$oldVersion!g" \
			-e "s!%%POSTGRES_NEW%%!$new!g" \
			-e "s!%%SUITE%%!$suite!g" \
			Dockerfile.template \
			> "$dir/Dockerfile"
		cp docker-upgrade "$dir/"
		if [[ "$old" != 9.* ]]; then
			sed -i '/postgresql-contrib-/d' "$dir/Dockerfile"
		fi
	done
done

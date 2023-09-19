#!/usr/bin/env bash
set -Eeuo pipefail

# TODO scrape this somehow?
supportedVersions=(
	16
	15
	14
	13
	12
	11
	#10
	#9.6
	#9.5
	#9.4
	#9.3
	#9.2
)
suite='bookworm'

json='{}'

for i in "${!supportedVersions[@]}"; do
	new="${supportedVersions[$i]}"
	echo "# $new"
	docker pull "postgres:$new-$suite" > /dev/null
	(( j = i + 1 ))
	for old in "${supportedVersions[@]:$j}"; do
		dir="$old-to-$new"
		echo "- $old -> $new ($dir)"
		from="postgres:$new-$suite"
		oldVersion="$(
			docker run --rm -e OLD="$old" "$from" bash -Eeuo pipefail -c '
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
		json="$(jq <<<"$json" -c --arg dir "$dir" --arg version "$oldVersion" --arg from "$from" --arg old "$old" --arg new "$new" '
			.[$dir] = {
				from: $from,
				new: $new,
				old: $old,
				version: $version,
			}
		')"
	done
done

jq <<<"$json" '.' > versions.json

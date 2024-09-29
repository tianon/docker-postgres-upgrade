#!/usr/bin/env bash
set -Eeuo pipefail

doiCommit="$(git ls-remote https://github.com/docker-library/official-images.git HEAD | cut -d$'\t' -f1)"
doiPostgres="https://github.com/docker-library/official-images/raw/$doiCommit/library/postgres"
versions="$(
	bashbrew list "$doiPostgres" | jq -nR '
		[
			inputs
			# filter tags down to just "N-XXX" (capturing "version" and "debian suite")
			| capture(":(?<version>[0-9]+)-(?<suite>[a-z].*)$")
			| select(.suite | startswith("alpine") | not)
		]
	'
)"
supportedVersions="$(jq <<<"$versions" -r '[ .[].version | tonumber ] | unique | reverse | map(@sh) | join(" ")')"
eval "supportedVersions=( $supportedVersions )"

json='{}'

for i in "${!supportedVersions[@]}"; do
	new="${supportedVersions[$i]}"
	export new
	suites="$(jq <<<"$versions" -c '[ .[] | select(.version == env.new).suite ]')"
	echo "# $new (possible suites: $suites)"
	(( j = i + 1 ))
	for old in "${supportedVersions[@]:$j}"; do
		export old
		suite="$(jq <<<"$versions" --argjson suites "$suites" -r '
			first(
				.[]
				| select(
					.version == env.old
						and (
							.suite as $suite
							| $suites | index($suite)
						)
				)
			).suite
		')"
		from="postgres:$new-$suite"
		fromAlpine="postgres:$new-alpine"
		dir="$old-to-$new"
		export suite from fromAlpine dir
		echo "- $old -> $new ($dir; $suite)"
		postgresCommit="$(bashbrew cat --format '{{ .TagEntry.GitCommit }}' "$doiPostgres:$old-$suite")"
		versionsURL="https://github.com/docker-library/postgres/raw/$postgresCommit/versions.json"
		oldVersion="$(wget -qO- "$versionsURL" | jq -r '.[env.old][env.suite].version // empty')" # TODO arches? (would need to cross-reference $new's arches, but that's fair / not too difficult)
		echo "  - $oldVersion"
		[ -n "$oldVersion" ]
		export oldVersion
		json="$(jq <<<"$json" -c '
			.[env.dir] = {
				from: env.from,
				fromAlpine: env.fromAlpine,
				new: env.new,
				old: env.old,
				version: env.oldVersion,
			}
		')"
	done
done

jq <<<"$json" '.' > versions.json

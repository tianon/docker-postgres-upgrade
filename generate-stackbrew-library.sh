#!/usr/bin/env bash
set -Eeuo pipefail

self="$(basename "$BASH_SOURCE")"
cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

if [ "$#" -eq 0 ]; then
	versions="$(jq -r 'keys_unsorted | map(@sh) | join(" ")' versions.json)"
	eval "set -- $versions"
fi

commit="$(git log -1 --format='format:%H' HEAD)"

cat <<-EOH
	Maintainers: Tianon Gravi <tianon@tianon.xyz> (@tianon)
	GitRepo: https://github.com/tianon/docker-postgres-upgrade.git
	GitCommit: $commit
EOH

for version; do
	export version

	cat <<-EOE

		Tags: $version
		Directory: $version
	EOE
done

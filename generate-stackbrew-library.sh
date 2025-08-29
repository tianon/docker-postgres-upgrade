#!/usr/bin/env bash
set -Eeuo pipefail

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

commit="$(git log -1 --format='format:%H' HEAD)"

exec jq \
	--raw-output \
	--arg commit "$commit" \
	--from-file generate-stackbrew-library.jq \
	versions.json \
	--args -- "$@"

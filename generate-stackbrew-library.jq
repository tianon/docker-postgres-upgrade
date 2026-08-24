"Maintainers: Tianon Gravi <tianon@tianon.xyz> (@tianon)",
"GitRepo: https://github.com/tianon/docker-postgres-upgrade.git",
"GitCommit: \($commit)",

(
	first(.[].new) as $newest

	| to_entries[]

	| if $ARGS.positional | length > 0 then
		select(IN(.key; $ARGS.positional[]))
	else . end

	| (
		"",
		"Tags: \(.key)",
		"Directory: \(.key)",
		"Architectures: \(
			if .value.new == $newest then
				# only the newest (target) version gets more than one architecture
				# https://github.com/tianon/docker-postgres-upgrade/issues/99#issuecomment-3235566575
				"amd64, arm64v8"
				# TODO update "versions.sh" to also scrape/keep "Architectures" data from the upstream bashbrew files so this doesn't ever accidentally include things that don't exist or shouldn't be supported
			else "amd64" end
		)",
		empty
	)
)

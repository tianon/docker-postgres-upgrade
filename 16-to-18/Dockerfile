#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM postgres:18-trixie

RUN sed -i 's/$/ 16/' /etc/apt/sources.list.d/pgdg.list

RUN set -eux; \
	apt-get install --update -y --no-install-recommends \
		postgresql-16='16.13-1.pgdg13+1' \
	; \
	apt-get dist-clean

ENV PGBINOLD /usr/lib/postgresql/16/bin
ENV PGBINNEW /usr/lib/postgresql/18/bin
RUN set -eux; \
	"$PGBINOLD/postgres" --version; \
	"$PGBINNEW/postgres" --version

ENV PGDATAOLD /var/lib/postgresql/16/data
ENV PGDATANEW /var/lib/postgresql/18/docker

RUN install \
		--verbose \
		--owner postgres \
		--group postgres \
		--mode 1777 \
		--directory \
		"$PGDATAOLD" \
		"$PGDATANEW"

WORKDIR /var/lib/postgresql

COPY docker-upgrade /usr/local/bin/

ENTRYPOINT ["docker-upgrade"]

# recommended: --link
CMD ["pg_upgrade"]

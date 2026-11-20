#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM postgres:19-trixie

RUN sed -i 's/$/ 18/' /etc/apt/sources.list.d/pgdg.list

RUN set -eux; \
	apt-get install --update -y --no-install-recommends \
		postgresql-18='18.7-1.pgdg13+5' \
	; \
	apt-get dist-clean

ENV PGBINOLD /usr/lib/postgresql/18/bin
ENV PGBINNEW /usr/lib/postgresql/19/bin
RUN set -eux; \
	"$PGBINOLD/postgres" --version; \
	"$PGBINNEW/postgres" --version

ENV PGDATAOLD /var/lib/postgresql/18/docker
ENV PGDATANEW /var/lib/postgresql/19/docker

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

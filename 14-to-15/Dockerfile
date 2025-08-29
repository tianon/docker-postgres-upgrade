#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM postgres:15-trixie

RUN sed -i 's/$/ 14/' /etc/apt/sources.list.d/pgdg.list

RUN set -eux; \
	apt-get install --update -y --no-install-recommends \
		postgresql-14='14.19-1.pgdg13+1' \
	; \
	apt-get dist-clean

ENV PGBINOLD /usr/lib/postgresql/14/bin
ENV PGBINNEW /usr/lib/postgresql/15/bin
RUN set -eux; \
	"$PGBINOLD/postgres" --version; \
	"$PGBINNEW/postgres" --version

ENV PGDATAOLD /var/lib/postgresql/14/data
ENV PGDATANEW /var/lib/postgresql/15/data

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

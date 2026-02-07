FROM registry:3

RUN apk add --no-cache apache2-utils gettext

COPY config.yml /railway/config.yml.tmpl
COPY entrypoint.sh /railway/entrypoint.sh
RUN chmod +x /railway/entrypoint.sh

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD wget -q --spider http://localhost:5000/v2/ || exit 1

ENTRYPOINT ["/railway/entrypoint.sh"]

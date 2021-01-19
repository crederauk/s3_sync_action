FROM python:3.8-alpine

ENV AWSCLI_VERSION='1.18.14'

RUN apk update \
    && apk upgrade \
    && apk add --no-cache --update coreutils bash \
    && rm -rf /var/cache/apk/* \
    && pip install --quiet --no-cache-dir awscli==${AWSCLI_VERSION}

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

FROM alpine:3.19

RUN apk add --no-cache openssh-server netcat-openbsd bash

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 22 8080

ENTRYPOINT ["/entrypoint.sh"]

# syntax=docker/dockerfile:1
FROM alpine:3.19 AS builder

#do kompilacji i Gita
RUN apk add --no-cache gcc musl-dev git
WORKDIR /src

#pobranie z repo uzywajac sekretu
#kod nie musi byc kopiowany z dysku lokalnego
RUN --mount=type=secret,id=git_token \
    export GIT_TOKEN=$(cat /run/secrets/git_token) && \
    git clone https://${GIT_TOKEN}@github.com/PAwCOKM/PAwChO_Zadanie1.git . && \
    gcc -static -Os -s -o server server.c

FROM scratch
LABEL org.opencontainers.image.authors="Kacper Madyński"
LABEL org.opencontainers.image.title="Zadanie 1 - Wersja Dodatkowa"

ENV TZ="CET-1CEST,M3.5.0,M10.5.0/3"

COPY --from=builder /src/server /server
EXPOSE 8080

HEALTHCHECK --interval=10s --timeout=3s --retries=3 \
    CMD ["/server", "--healthcheck"]

CMD ["/server"]

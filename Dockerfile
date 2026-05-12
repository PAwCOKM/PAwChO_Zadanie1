#wieloetapowe budowanie obrazu
FROM alpine:3.19 AS builder

#instalacja kompilatora GCC i MUSL
RUN apk add --no-cache gcc musl-dev
WORKDIR /src

#kopiowanie kodu na koncu etapu dla optymalizacji cache
COPY server.c ./

#kompilacja kodu do pojedynczego pliku:
#-static (niezbedne dla scratch)
#-Os najmniejszy rozmiar
#-s usuwa tabele symboli
RUN gcc -static -Os -s -o server server.c

#minimalny obraz koncowy
FROM scratch

#etykiety zgodnie z OCI
LABEL org.opencontainers.image.authors="Kacper Madyński"
LABEL org.opencontainers.image.title="Zadanie 1"

#strefa czasowa w formacie POSIX
ENV TZ="CET-1CEST,M3.5.0,M10.5.0/3"

#kopiowanie tylko binarium z pierwszego etapu
COPY --from=builder /src/server /server

#port sieciowy
EXPOSE 8080

#uruchamia skompilowana aplikacje, unikajac zewnetrznego curla i dodatkowych warstw
HEALTHCHECK --interval=10s --timeout=3s --retries=3 \
    CMD ["/server", "--healthcheck"]

#punkt wejscia dla kontenera
CMD ["/server"]

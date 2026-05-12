#wieloetapowe budowanie obrazu
FROM alpine:3.19 AS builder

#instalacja kompilatora GCC i MUSL
RUN apk add --no-cache gcc musl-dev

#tworzenie uzytkownika bez uprawnien systemowych
RUN adduser -D -H -u 10001 appuser

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

#kopiowanie plikow identyfikacyjnych uzytkownika
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group

#kopiowanie tylko binarium z pierwszego etapu
COPY --from=builder /src/server /server

#zmiana kontekstu na uzytkownika nieuprzywilejowanego
USER appuser

#port sieciowy
EXPOSE 8080

#uruchamia skompilowana aplikacje, unikajac zewnetrznego curla i dodatkowych warstw
HEALTHCHECK --interval=10s --timeout=3s --retries=3 \
    CMD ["/server", "--healthcheck"]

#punkt wejscia dla kontenera
CMD ["/server"]

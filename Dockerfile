FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y sqlite3

WORKDIR /usr/src/atom

COPY target/x86_64-unknown-linux-gnu/release/atom .
COPY .env .

COPY atom.db atom.db

EXPOSE 8080

CMD ["./atom"]
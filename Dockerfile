# stage 1: build
FROM golang:1.24 AS builder
WORKDIR /app

# copy dependencies
COPY go.mod go.sum ./
RUN go mod download

# copy source files
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o ./bin/api ./cmd/api

FROM alpine:latest
WORKDIR /app

COPY --from=builder /app/bin/api .

COPY --from=builder /app/migrations ./migrations

EXPOSE 4000

CMD ["./api"]
FROM golang:1.23-alpine AS builder
WORKDIR /src
COPY main.go .
RUN go mod init mcp-client && go build -o mcp-client .

FROM alpine:3.21
COPY --from=builder /src/mcp-client /usr/local/bin/mcp-client
ENTRYPOINT ["mcp-client"]

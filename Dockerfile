FROM golang:1-alpine as builder

WORKDIR /usr/src/app

# pre-copy/cache go.mod for pre-downloading dependencies and only redownloading them in subsequent builds if they change
COPY go.mod go.sum ./
RUN go mod download && go mod verify

COPY . .

# Create a static binary
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o /go/bin/server ./cmd/main.go

# Create a minimal container to run a Golang static binary
FROM scratch

ENV GIN_MODE=release

# Copy our static executable.
COPY --from=builder /go/bin/server /server

EXPOSE 8080

ENTRYPOINT ["/server"]
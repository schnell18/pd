FROM golang:1.16-alpine as builder

ARG APK_MIRROR="mirrors.tuna.tsinghua.edu.cn"
# switch to local mirror
RUN sed -i "s/dl-cdn.alpinelinux.org/${APK_MIRROR}/g" /etc/apk/repositories

RUN apk add --no-cache \
    make \
    git \
    bash \
    curl \
    gcc \
    g++

RUN mkdir -p /go/src/github.com/tikv/pd
WORKDIR /go/src/github.com/tikv/pd

# Cache dependencies
COPY go.mod .
COPY go.sum .

RUN go env -w GO111MODULE=on && \
    go env -w GOPROXY=https://goproxy.cn,direct && \
    go mod download

COPY . .

RUN make

FROM alpine:3.14

ARG APK_MIRROR="mirrors.tuna.tsinghua.edu.cn"
# switch to local mirror
RUN sed -i "s/dl-cdn.alpinelinux.org/${APK_MIRROR}/g" /etc/apk/repositories

RUN apk add --no-cache jq

COPY --from=builder /go/src/github.com/tikv/pd/bin/pd-server /pd-server
COPY --from=builder /go/src/github.com/tikv/pd/bin/pd-ctl /pd-ctl
COPY --from=builder /go/src/github.com/tikv/pd/bin/pd-recover /pd-recover

EXPOSE 2379 2380

ENTRYPOINT ["/pd-server"]

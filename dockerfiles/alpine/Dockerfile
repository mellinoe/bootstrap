FROM alpine:latest
RUN apk update
RUN apk add bash gcc clang clang-dev cmake make build-base icu-dev python gettext-dev zlib-dev curl-dev krb5-dev linux-headers git llvm autoconf libtool

# Other sources
RUN apk -X https://dl-cdn.alpinelinux.org/alpine/edge/main add --no-cache libunwind-dev util-linux-dev
RUN apk -X https://dl-cdn.alpinelinux.org/alpine/edge/testing add --no-cache lldb-dev lttng-ust-dev
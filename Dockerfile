# dynamic config
ARG             BUILD_DATE
ARG             VCS_REF
ARG             VERSION

# build
FROM            golang:1.23-alpine as builder
RUN             apk add --no-cache git gcc musl-dev make binutils-gold
# CGO_CFLAGS="-D_LARGEFILE64_SOURCE" to fix a bug: https://github.com/mattn/go-sqlite3/issues/1164#issuecomment-1635253695
ENV             GO111MODULE=on CGO_CFLAGS="-D_LARGEFILE64_SOURCE"
WORKDIR         /go/src/berty.tech/berty
COPY            go.* ./
RUN             go mod download
COPY            ./go ./go
COPY            ./.git ./.git
WORKDIR         /go/src/berty.tech/berty/go
RUN             make go.install

# minimalist runtime
FROM            alpine:3.16.2
RUN             apk add --no-cache ncurses
LABEL           org.label-schema.build-date=$BUILD_DATE \
                org.label-schema.name="berty" \
                org.label-schema.description="" \
                org.label-schema.url="https://berty.tech/" \
                org.label-schema.vcs-ref=$VCS_REF \
                org.label-schema.vcs-url="https://github.com/berty/berty" \
                org.label-schema.vendor="Berty Technologies" \
                org.label-schema.version=$VERSION \
                org.label-schema.schema-version="1.0" \
                org.label-schema.cmd="docker run -i -t --rm bertytech/berty" \
                org.label-schema.help="docker exec -it $CONTAINER berty --help"
COPY            --from=builder /go/bin/berty /go/bin/rdvp /go/bin/welcomebot /go/bin/testbot /go/bin/berty-integration /bin/
ENTRYPOINT      ["/bin/berty"]
#CMD            []
